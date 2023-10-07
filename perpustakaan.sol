// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
contract Perpustakaan {

    address public admin;
    
    struct Book {
        uint256 kodeIsbn;
        string judulBuku;
        uint16 tahun;
        string penulis;
    }
    
    mapping(uint256 => Book) public books;
    uint256 public jumlahBuku;
    bool public isBookUpdatePending;
    Book public pendingBookData;
    
    event BookAdded(uint256 kodeIsbn, string judulBuku, uint16 tahun, string penulis);
    event BookDeleted(uint256 kodeIsbn);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }
    
    constructor() {
        admin = msg.sender;
    }

    function setAdmin(address _admin) public {
        require(msg.sender == admin, "Only current admin can set a new admin");
        // require(_admin != address(0), "Invalid admin address");
        admin = _admin;
    }

    function addBook(uint256 _kodeIsbn, string calldata _judul, uint16 _tahun, string calldata _penulis) public onlyAdmin {
        require(_kodeIsbn > 0, "Invalid ISBN code");

        // membuat data buku untuk dimasukkan ke daftar pending
        pendingBookData = Book({
            kodeIsbn: _kodeIsbn,
            judulBuku: _judul,
            tahun: _tahun,
            penulis: _penulis
        });

        // menandakan ada data yang pending
        isBookUpdatePending = true;
    }

    function updateBook() public onlyAdmin {
        require(isBookUpdatePending, "No pending book data to update");

        // Simpan data buku yang tertunda ke pemetaan
        books[pendingBookData.kodeIsbn] = pendingBookData;
        jumlahBuku++;

        // Reset data buku yang pending ke nilai awal
        pendingBookData = Book({
            kodeIsbn: 0,
            judulBuku: "",
            tahun: 0,
            penulis: ""
        });

        // Setel ulang data dan tandai buku yang tertunda
        isBookUpdatePending = false;

        emit BookAdded(pendingBookData.kodeIsbn, pendingBookData.judulBuku, pendingBookData.tahun, pendingBookData.penulis);
    }

    function deleteBook(uint256 _kodeIsbn) public onlyAdmin {
        require(books[_kodeIsbn].kodeIsbn != 0, "Book with specified ISBN not found");
        // membuat data buku untuk dimasukkan ke daftar pending
        pendingBookData = Book({
            kodeIsbn: _kodeIsbn,
            judulBuku: _judul,
            tahun: _tahun,
            penulis: _penulis
        });

        // menandakan ada data yang pending
        isBookUpdatePending = true;
        // hapus buku dari mappping
        delete books[_kodeIsbn];

        // pengurangan jumlah buku
        jumlahBuku--;

        emit BookDeleted(_kodeIsbn);
    }
}
