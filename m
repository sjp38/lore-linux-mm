Date: Tue, 31 Oct 2000 01:30:46 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.4.0-test10-pre6  TLB flush race in establish_pte
Message-ID: <20001031013046.M21935@athlon.random>
References: <OFB4731A18.0D8D8BC1-ON85256988.0074562B@raleigh.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <OFB4731A18.0D8D8BC1-ON85256988.0074562B@raleigh.ibm.com>; from slpratt@us.ibm.com on Mon, Oct 30, 2000 at 03:31:22PM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steve Pratt/Austin/IBM <slpratt@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 30, 2000 at 03:31:22PM -0600, Steve Pratt/Austin/IBM wrote:
> [..] no patch ever
> appeared. [..]

You didn't followed l-k closely enough as the strict fix was submitted two
times but it got not merged. (maybe because it had an #ifdef __s390__ that was
_necessary_ by that time?)

You can find the old and now useless patch here:

	ftp://ftp.us.kernel.org/pub/linux/kernel/people/andrea/patches/v2.4/2.4.0-test5/tlb-flush-smp-race-1

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
