Message-Id: <l0313030fb70791aa88ae@[192.168.239.105]>
In-Reply-To: <3AE1DCA8.A6EF6802@earthlink.net>
References: <mibudt848g9vrhaac88qjdpnaut4hajooa@4ax.com>
 <Pine.LNX.4.30.0104201203280.20939-100000@fs131-224.f-secure.com>
 <sb72ets3sek2ncsjg08sk5tmj7v9hmt4p7@4ax.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Sat, 21 Apr 2001 20:41:40 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Joseph A. Knapka" <jknapka@earthlink.net>, "James A. Sutherland" <jas88@cam.ac.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> Note that process suspension already happens, but with too fine a
>> granularity (the scheduler) - that's what causes the problem. If one
>> process were able to run uninterrupted for, say, a second, it would
>> get useful work done, then you could switch to another. The current
>> scheduling doesn't give enough time for that under thrashing
>> conditions.
>
>This suggests that a very simple approach might be to just increase
>the scheduling granularity as the machine begins to thrash. IOW,
>use the existing scheduler as the "suspension scheduler".

That might possibly work for some loads, mostly where there are some
processes which are already swapped-in (and have sensible working sets)
alongside the "thrashing" processes.  That would at least give the
well-behaved processes some chance to keep their "active" bits up to date.

However, it doesn't help at all for the cases where some paging-in has to
be done for a well-behaved but only-just-accessed process.  Example of a
critically important process under this category: LOGIN.  :)  IMHO, the
only way to sensibly cater for this case (and a few others) is to update
the page-replacement algorithm.

--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)
big-mail: chromatix@penguinpowered.com
uni-mail: j.d.morton@lancaster.ac.uk

The key to knowledge is not to rely on people to teach you it.

Get VNC Server for Macintosh from http://www.chromatix.uklinux.net/vnc/

-----BEGIN GEEK CODE BLOCK-----
Version 3.12
GCS$/E/S dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$ V? PS
PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)
-----END GEEK CODE BLOCK-----


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
