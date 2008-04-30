Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3UK3Y0W018567
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 16:03:34 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3UK3Y68142798
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 14:03:34 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3UK3Lnc021755
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 14:03:31 -0600
Date: Wed, 30 Apr 2008 13:02:49 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 17/18] x86: add hugepagesz option on 64-bit
Message-ID: <20080430200249.GA6903@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015431.462123000@nick.local0.net> <20080430193416.GE8597@us.ibm.com> <20080430195237.GE20451@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080430195237.GE20451@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 30.04.2008 [21:52:37 +0200], Andi Kleen wrote:
> > I want to make sure struct hstate is
> > future-proofed for other architectures than x86_64...
> 
> Kernel code doesn't need to be future-proof, because it can be changed
> at any time.

Then let's just merge whatever we'd like all the time? Why have review
at all?

To quote Nick from a separate discussion on similar future-proofing:

"Let's really try to put some thought into new sysfs locations. Not just
will it work, but is it logical and will it work tomorrow..."

So maybe future-proof is the wrong term, but I want to make sure the
infrastructure we have in place, where it claims to be generic and
usable by architectures (as has been my impression from the discussions
so far -- that it is extensible to other architectures), I want to be
sure that is really the case.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
