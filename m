Mime-Version: 1.0
Message-Id: <a05111b3bb98b92742c91@[192.168.239.105]>
In-Reply-To: <Pine.OSF.4.10.10208231100500.4550-100000@moon.cdotd.ernet.in>
References: <Pine.OSF.4.10.10208231100500.4550-100000@moon.cdotd.ernet.in>
Date: Fri, 23 Aug 2002 09:26:57 +0200
From: Jonathan Morton <chromi@chromatix.demon.co.uk>
Subject: Re: ramfs/tmpfs/shmfs  doubt
Content-Type: text/plain; charset="us-ascii" ; format="flowed"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anil Kumar <anilk@cdotd.ernet.in>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>    I am planning to create a file system at boot time in RAM and download
>application binaries to that and run.RAM is limited so my  requirement is
>that i do not want to have two copies of data in the RAM (One in File
>System i create and other one in Page Cache ).

Tmpfs and shmfs are two names for the same thing (the latter is 
deprecated), and I believe it will do what you want.  It exists in 
the pagecache, and I understand this is routinely mapped into process 
space for execution.

Ramfs creates a whole new section of memory and treats it as a block 
device, and the pagecache is used in addition to that.  This is not 
what you want, and I understand ramfs itself is discouraged since 
tmpfs is now in widespread use.  Cramfs is still useful as it uses 
compression on the "block device".

>   Can i run a linux kernel disabling swapping (In my case no
>  additional device for swap is available) ?

Certainly.  Simply don't provide a swap device or run swapon.  It'll 
work just fine until you run out of RAM, in which case you'd be 
screwed in any case.  :o)  I naturally assume you'll be running quite 
lean and tightly-controlled apps on that.

-- 
--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@chromatix.demon.co.uk
website:  http://www.chromatix.uklinux.net/
geekcode: GCS$/E dpu(!) s:- a21 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$
           V? PS PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)
tagline:  The key to knowledge is not to rely on people to teach you it.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
