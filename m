Message-Id: <l03130312b7444bea56f8@[192.168.239.105]>
In-Reply-To: 
        <Pine.LNX.4.21.0106061618330.3769-100000@freak.distro.conectiva>
References: <l03130308b7439bb9f187@[192.168.239.105]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 6 Jun 2001 22:13:31 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: [PATCH] reapswap for 2.4.5-ac10
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> *** UPDATE *** : I applied the patch, and it really does help.  Compile
>> time for MySQL is down to ~6m30s from ~8m30s with 48Mb physical, and the
>> behaviour after the monster file is finished is much improved.  For
>> reference, the MySQL compile takes ~5min on this box with all 256Mb
>> available.  It's a 1GHz Athlon.
>
>Which patch ? :)

The one which deals with dead swapcache pages.  I want to apply the one
which actively eats them using kreclaimd, too.

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
