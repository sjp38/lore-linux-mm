Date: Sun, 27 May 2001 22:20:20 +0200
From: bert hubert <ahu@ds9a.nl>
Subject: http://ds9a.nl/cacheinfo project - please comment & improve
Message-ID: <20010527222020.A25390@home.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello mm people!

I've written a module plus a tiny userspace program to query the page
cache. In short:

$ cinfo /lib/libc.so.6
/lib/libc.so.6: 182 of 272 (66.91%) pages in the cache, of which 0 (0.00%)
are dirty

Now, I'm a complete and utter beginner when it comes to kernelcoding. Also,
this is very much a 'release early, release often'-release. In other words,
it sucks & I know.

So I would like to ask you to look at it and send comments/patches to me.
I'm especially interested in architectural decisions - I currently export
data over a filesystem (cinfofs), which may or not be right.

The tarball (http://ds9a.nl/cacheinfo/cinfo-0.1.tar.gz) contains 2 manpages
which very lightly document how it works.

Thanks for your time!

Regards,

bert hubert

-- 
http://www.PowerDNS.com      Versatile DNS Services  
Trilab                       The Technology People   
'SYN! .. SYN|ACK! .. ACK!' - the mating call of the internet
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
