Received: from dolphin.chromatix.org.uk ([192.168.239.105])
	by helium.chromatix.org.uk with esmtp (Exim 3.15 #5)
	id 1584RK-0002Ac-00
	for linux-mm@kvack.org; Thu, 07 Jun 2001 19:23:26 +0100
Message-Id: <l03130319b74575102756@[192.168.239.105]>
In-Reply-To: <l03130318b74568171b40@[192.168.239.105]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 7 Jun 2001 19:23:20 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: VM tuning patch, take 2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>I'm just about to test single-threaded compilation with 48Mb and 32Mb
>physical RAM, for comparison.  Previous best times are 6m30s and 2h15m
>respectively...

...which have now completed.  Results as follows:

mem=	2.4.5		earlier tweaks	now
48M	8m30s		6m30s		5m58s
32M	unknown		2h15m		12m34s

That's some improvement!  :D  Now to do the cleanups and make the diff.

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
