Subject: 2.2.11 - the new physical memory `fix' / i386
Reply-To: colin@field.medicine.adelaide.edu.au
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: Thu, 19 Aug 1999 01:49:11 +1000
From: Colin McCormack <colin@field.medicine.adelaide.edu.au>
Message-Id: <19990818154935Z17786-657+3@eeyore.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

According to /proc/maps, the kernel mmaps the range of addresses up to and 
including 0x80000000 if you tell config you have 2Gb of physical RAM.  I 
suppose it mmaps up to and including 0x40000000 if you tell it you have 1Gb, 
and 0xC0000000 if you tell it you have 3Gb.

Leaving aside the question of why it should be mmapping like this at all ... 
is there some good reason you would want a machine with (say) 2GB of ram to 
have a map including the first byte of the 3rd gigabyte of address space?

I suspect there's an off-by-one error, and the map should end within the 
stated range (e.g. 0x40000000-1).  This causes me problems in ColdStore, 
http://field.medicine.adelaide.edu.au/~colin/coldstore, where I'd like to be 
able to map in some memory at a fixed address, and 0x40000000 looks a lot 
better than 0x40000000 + 4096.

Incidentally, as far as fixing the problem of linux not handling 2GB of RAM, 
there's a much simpler way:  send 1/2 of it to me :)

Colin.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
