Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 9B02D6B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 18:16:34 -0400 (EDT)
From: Harald Glatt <mail@hachre.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Subject: scan_unevictable_pages sysctl/node-interface
Message-Id: <9EEC7022-38C5-46B8-8825-9FA4E98F6CF6@hachre.de>
Date: Tue, 15 May 2012 00:16:30 +0200
Mime-Version: 1.0 (Mac OS X Mail 6.0 \(1457\))
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hey,

I'm reshaping my raid5 to raid6 in linux 3.3.2 with mdadm 3.2.3 atm and =
I got this messages in dmesg:

[390496.114687] md: reshape of RAID array md0
[390496.114692] md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
[390496.114697] md: using maximum available idle IO bandwidth (but not =
more than 200000 KB/sec) for reshape.
[390496.114707] md: using 128k window, over a total of 1465138496k.
[390751.722771] sysctl: The scan_unevictable_pages sysctl/node-interface =
has been disabled for lack of a legitimate use case.  If you have one, =
please send an email to linux-mm@kvack.org.

Maybe its a use case I don't know :) Just thought I'd give you a heads =
up. So far it seems to continue without a problem though!

Harald=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
