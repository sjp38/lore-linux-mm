Mime-Version: 1.0
Message-Id: <a05100302b7d55fc15ab3@[192.168.239.101]>
In-Reply-To: <5D2F375D116BD111844C00609763076E050D167E@exch-staff1.ul.ie>
References: <5D2F375D116BD111844C00609763076E050D167E@exch-staff1.ul.ie>
Date: Mon, 24 Sep 2001 23:16:15 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: RE: Process not given >890MB on a 4MB machine ?????????
Content-Type: text/plain; charset="us-ascii" ; format="flowed"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Gabriel.Leen" <Gabriel.Leen@ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>	Unfortunately my program which is doing "alot" of calculations still
>needs more space,
>
>	Is there some way to enable 64 bit support (or something) and get
>the swap space active,
>	and give it another GB or so ?

Nope, I doubt it.  The x86 architecture is fundamentally 32-bit, and 
thus can't address more than 4Gb for a single process - 1Gb of that 
address space is reserved for the kernel.  You can confirm this by 
looking at the result of sizeof(void*).

You will either need to use a true 64-bit machine (POWER, Alpha, 
UltraSPARC or MIPS) or rewrite your program to use large files 
instead of large amounts of memory.  I suspect the latter would be 
less costly.

-- 
--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)
website:  http://www.chromatix.uklinux.net/vnc/
geekcode: GCS$/E dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$
           V? PS PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)
tagline:  The key to knowledge is not to rely on people to teach you it.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
