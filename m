Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2]) by pneumatic-tube.sgi.com (980327.SGI.8.8.8-aspam/980310.SGI-aspam) via ESMTP id KAA06567
	for <@external-mail-relay.sgi.com:linux-mm@kvack.org>; Mon, 25 Oct 1999 10:28:38 -0700 (PDT)
	mail_from (wje@liveoak.engr.sgi.com)
Received: from liveoak.engr.sgi.com (liveoak.engr.sgi.com [150.166.40.92])
	by cthulhu.engr.sgi.com (980427.SGI.8.8.8/970903.SGI.AUTOCF)
	via ESMTP id KAA03498
	for <linux-mm@kvack.org>;
	Mon, 25 Oct 1999 10:27:46 -0700 (PDT)
	mail_from (wje@liveoak.engr.sgi.com)
From: "William J. Earl" <wje@cthulhu.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14356.37630.420222.582735@liveoak.engr.sgi.com>
Date: Mon, 25 Oct 1999 10:27:26 -0700 (PDT)
Subject: Re: page faults
In-Reply-To: <m1wvsc8ytq.fsf@flinx.hidden>
References: <Pine.LNX.4.10.9910221930070.172-100000@imperial.edgeglobal.com>
	<m1wvsc8ytq.fsf@flinx.hidden>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Eric W. Biederman writes:
...
 > If the hardware cannot support two processors hitting the region simultaneously,
 > (support would be worst case the graphics would look strange)
 > you could have problems.
...
      One could reasonably take the view that a threads-aware graphics library
should be thread-safe.  That is, if the hardware needs to have concurrent
threads in a single process serialize access to the hardware, then the 
library plugin for that hardware should do the required serialization.

      This of course the neglects the question of whether a broken
user-mode program could damage the hardware, but then a broken
single-threaded user-mode program, with no other programs using the
hardware, could just as easily damage the hardware.  That is, if the
hardware is not safe for direct access in general, threading does not
make it any less safe.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
