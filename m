Subject: Re: 2.4.0-test3-pre2: corruption in mm?
References: <3961A761.974CED49@norran.net>
From: "John Fremlin" <vii@penguinpowered.com>
Date: 04 Jul 2000 17:18:27 +0100
In-Reply-To: Roger Larsson's message of "Tue, 04 Jul 2000 10:59:13 +0200"
Message-ID: <m28zvh50oc.fsf@boreas.southchinaseas>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, Roger Larsson <roger.larsson@norran.net>
List-ID: <linux-mm.kvack.org>

Roger Larsson <roger.larsson@norran.net> writes:

> When I booted up today mount complained that one of my disks
> was not ok. (/usr)

I had ext2fs corruption (plain 2.4.0-test2) when installing a new
sendmail. (Which is why I'm not testing out any VM patches on test2,
sorry Roger). One of the man page's got a lot of really wacky block
numbers when installed. The first part was there but trying to read
the tail got:

Jul  1 23:01:59 localhost kernel: attempt to access beyond end of device 
Jul  1 23:01:59 localhost kernel: 03:06: rw=0, want=1513321072, limit=2096451 
Jul  1 23:01:59 localhost kernel: attempt to access beyond end of device 
Jul  1 23:01:59 localhost kernel: 03:06: rw=0, want=1867003509, limit=2096451 
Jul  1 23:01:59 localhost kernel: attempt to access beyond end of device 
Jul  1 23:01:59 localhost kernel: 03:06: rw=0, want=1919247469, limit=2096451 
Jul  1 23:01:59 localhost kernel: attempt to access beyond end of device 
Jul  1 23:01:59 localhost kernel: 03:06: rw=0, want=808540722, limit=2096451 
Jul  1 23:02:01 localhost kernel: attempt to access beyond end of device 
Jul  1 23:02:01 localhost kernel: 03:06: rw=0, want=1513321072, limit=2096451 
Jul  1 23:02:01 localhost kernel: attempt to access beyond end of device 
Jul  1 23:02:01 localhost kernel: 03:06: rw=0, want=1867003509, limit=2096451 
Jul  1 23:02:01 localhost kernel: attempt to access beyond end of device 
Jul  1 23:02:01 localhost kernel: 03:06: rw=0, want=1919247469, limit=2096451 
Jul  1 23:02:01 localhost kernel: attempt to access beyond end of device 
Jul  1 23:02:01 localhost kernel: 03:06: rw=0, want=808540722, limit=2096451 
Jul  1 23:03:20 localhost kernel: attempt to access beyond end of device 
Jul  1 23:03:20 localhost kernel: 03:06: rw=0, want=1513321072, limit=2096451 
Jul  1 23:03:20 localhost kernel: attempt to access beyond end of device 
Jul  1 23:03:20 localhost kernel: 03:06: rw=0, want=1867003509, limit=2096451 

[...]

I thought I kept the fsck report, but I can't find it now.

-- 

	http://web.onetel.net.uk/~elephant/john
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
