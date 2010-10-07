Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 689156B0071
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 03:36:37 -0400 (EDT)
Date: Thu, 7 Oct 2010 09:36:33 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 2/4] HWPOISON: Copy si_addr_lsb to user
Message-ID: <20101007073633.GF5010@basil.fritz.box>
References: <1286398141-13749-1-git-send-email-andi@firstfloor.org>
 <1286398141-13749-3-git-send-email-andi@firstfloor.org>
 <4CAD6943.2020805@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CAD6943.2020805@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, fengguang.wu@intel.com, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 07, 2010 at 03:31:31PM +0900, Hidetoshi Seto wrote:
> (2010/10/07 5:48), Andi Kleen wrote:
> > From: Andi Kleen <ak@linux.intel.com>
> > 
> > The original hwpoison code added a new siginfo field si_addr_lsb to
> > pass the granuality of the fault address to user space. Unfortunately
> > this field was never copied to user space. Fix this here.
> > 
> > I added explicit checks for the MCEERR codes to avoid having
> > to patch all potential callers to initialize the field.
> 
> Now QEMU uses signalfd to catch the SIGBUS delivered to the
> main thread, so I think similar fix to copy lsb to user is
> required for signalfd too. 

Good catch. I don't think qemu uses this today, but it should
be fixed there too for .37 at least.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
