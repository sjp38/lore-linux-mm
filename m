Content-Type: text/plain;
  charset="iso-8859-1"
From: Thomas Hofer <th@monochrom.at>
Subject: Re: Changes in vm_operations_struct 2.2.x => 2.4.x
Date: Thu, 9 Aug 2001 14:24:39 +0200
References: <3B6A5A52.73D0DC12@scs.ch> <20010809004910.C1200@nightmaster.csn.tu-chemnitz.de> <3B72357E.1BF85B4B@scs.ch>
In-Reply-To: <3B72357E.1BF85B4B@scs.ch>
MIME-Version: 1.0
Message-Id: <01080914135800.01033@earth>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Martin Maletinsky wrote (Donnerstag,  9. August 2001 09:02):
> My module allocates a block of memory, and exports that block to user
> space processes, by registering as a character device and
> implementing a mmap file operation, so that user space processes can
> map that memory block into their virtual address space by calling
> mmap().

Would it be possible to do this with shared memory (shmget/shmat)? 
What's the advantage of making a device and mmaping it? Sounds 
more complicated. (I did only user-space programs as yet, so forgive me 
my naivity)

Thomas.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
