Received: from [192.168.7.150] (helo=johnson)
	by shitbox with smtp (Exim 3.36 #1 (Debian))
	id 19LFBJ-00013Z-00
	for <linux-mm@kvack.org>; Thu, 29 May 2003 00:38:25 -0400
Message-ID: <00f401c3259a$af9dc6d0$9607a8c0@johnson>
From: "Alain Toussaint" <alain@toussaint.dyndns.org>
References: <20030408042239.053e1d23.akpm@digeo.com> <3ED49A14.2020704@aitel.hist.no> <20030528111345.GU8978@holomorphy.com> <3ED49EB8.1080506@aitel.hist.no> <20030528113544.GV8978@holomorphy.com> <20030528225913.GA1103@hh.idb.hist.no>
Subject: Re: 2.5.70-mm1 bootcrash, possibly RAID-1
Date: Thu, 29 May 2003 00:27:59 -0400
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Unable to handle kernel paging request at virtual address 8a8a8ab6
> *pde=0 OOPS 0000 [#1]
> EIP at put_all_bios+0x47/0x80
> (edx was the register containing 8a8a8a8a)
> Process swapper pid=0 threadinfo c1352000 task=c13f52d0

I've seen something similar too when installing Gentoo on my box (stock
gentoo kernel 2.4.20 with the royal bunch of patch they put in),i was in the
bootstrap process building glibc,system is a Celery 566 with 512MB of ram (+
512MB of swap enabled during the install,don't think it was needed
though),the hard disk (maxtor 40GB) is hooked to a promise Ultra133TX2 card
but the dvd drive and the cd burner are hooked to the stock controller (Via
694Z mainboard),all are set to master,there's no slave device and the
computer has a gazillions fans making as much noise as a boeing 747 in order
to keep everything cool and i don't overclock.

Alain

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
