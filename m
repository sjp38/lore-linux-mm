Subject: Re: The 4GB memory thing
From: Andrea Arcangeli <andrea@suse.de>
Date: 04 Nov 1999 19:19:21 +0100
Message-ID: <m3aeou9l1y.fsf@alpha.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Neil Conway <nconway.list@ukaea.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

kanoj@google.engr.sgi.com (Kanoj Sarcar) writes:

> I have a 2.2 patch for 4Gb support, which has seen a lot of stress
> testing by now. The 2.3 >2gb support uses a different (and better
> approach), but last I checked, things like rawio did not work above
> >2Gb. The 64Gb support is completely new ...

2.2.13aa3 includes both 4g bigmem support and rawio and you can do
rawio on all the memory (bigmem included).

	ftp://ftp.*.kernel.org/pub/linux/kernel/people/andrea/kernels/v2.2/2.2.13aa3/

This is the README on how to go in sync with 2.2.13aa3:

	ftp://ftp.*.kernel.org/pub/linux/kernel/people/andrea/tools/apply-patches/README.gz

-- 
Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
