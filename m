Date: Mon, 10 Apr 2006 10:22:34 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC/PATCH] Shared Page Tables [0/2]
In-Reply-To: <1144685588.570.35.camel@wildcat.int.mccr.org>
Message-ID: <Pine.LNX.4.64.0604101020230.22947@schroedinger.engr.sgi.com>
References: <1144685588.570.35.camel@wildcat.int.mccr.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Adam Litke <agl@us.ibm.com>, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Mon, 10 Apr 2006, Dave McCracken wrote:

> Here's a new cut of the shared page table patch.  I divided it into
> two patches.  The first one just fleshes out the
> pxd_page/pxd_page_kernel macros across the architectures.  The
> second one is the main patch.
> 
> This version of the patch should address the concerns Hugh raised.
> Hugh, I'd appreciate your feedback again.  Did I get everything?
> 
> These patches apply against 2.6.17-rc1.

Could you break out the locking changes to huge pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
