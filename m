Mime-Version: 1.0
Message-Id: <a05111b09b96bcf853061@[192.168.239.105]>
In-Reply-To: <Pine.OSF.4.10.10207301003300.3850-100000@moon.cdotd.ernet.in>
References: <Pine.OSF.4.10.10207301003300.3850-100000@moon.cdotd.ernet.in>
Date: Tue, 30 Jul 2002 07:07:55 +0200
From: Jonathan Morton <chromi@chromatix.demon.co.uk>
Subject: Re: Regarding Page Cache ,Buffer Cachein  disabling in Linux
 Kernel.
Content-Type: text/plain; charset="us-ascii" ; format="flowed"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anil Kumar <anilk@cdotd.ernet.in>, Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>  a) i allow page caching then there is going to be 2 copies of
>   data in my system and i want to avoid it.

If you're using memory, the pages will be evicted from the cache.  It 
is NOT a problem.

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
