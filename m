Date: Fri, 13 Sep 2002 17:06:59 -0400
Mime-Version: 1.0 (Apple Message framework v482)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Subject: Obtaining the kernel's PTEs
From: Scott Kaplan <sfkaplan@cs.amherst.edu>
Content-Transfer-Encoding: 7bit
Message-Id: <BDF7B0A2-C75C-11D6-8D39-000393829FA4@cs.amherst.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Yet another question...

Assume that I'm not concerned with ZONE_HIGHMEM, and I have a struct page*
.  How would I obtain a pointer to the PTE that maps the corresponding 
virtual page in the kernel's address space to this given page?

In case you're wondering, ``Why does he want that?'':  I want to remove 
access permissions for pages, and I want to include the kernel in that 
denial of permission.  An example of where this matters is when you have a 
page cache page that was allocated by the VFS for read()/write() 
operations on a regular (non-mmaped) file.  Only the kernel has a mapping 
to that page, and I a trap to occur when the kernel tries to use that page.

Must I get the PGD, PMD, and then PTE?  Is there a function that will do 
this nicely for me so that I don't write redundant (and potentially buggy)
  code for this little task?

Scott
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (Darwin)
Comment: For info see http://www.gnupg.org

iD8DBQE9glN28eFdWQtoOmgRAof5AJ4tBOxrX6g74RiFezCQfrsooJjwLQCgq0V4
sH16r3mkat6WMtbqx9JcBbk=
=HSwE
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
