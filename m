Message-Id: <l03130300b74a2f8d4db6@[192.168.239.105]>
In-Reply-To: <01061023364200.03146@oscar>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 11 Jun 2001 09:20:58 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: what is using memory?
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>My box has
>
>320280K
>
>from proc/meminfo
>
> 17140	buffer
>123696	cache
> 32303	free
>
>leaving unaccounted
>
>123627K

This is your processes' memory, the inode and dentry caches, and possibly
some extra kernel memory which may be allocated after boot time.  It is
*very* much accounted for.

--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)

The key to knowledge is not to rely on people to teach you it.

GCS$/E/S dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$ V? PS
PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
