Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 246296B0062
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 11:48:35 -0400 (EDT)
Date: Tue, 10 Jul 2012 16:48:30 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: don't invoke __alloc_pages_direct_compact when order
 0
Message-ID: <20120710154829.GA9222@suse.de>
References: <1341588521-17744-1-git-send-email-js1304@gmail.com>
 <alpine.DEB.2.00.1207070139510.10445@chino.kir.corp.google.com>
 <CAAmzW4PXdpQ2zSnkx8sSScAt1OY0j4+HXVmf=COvP7eMLqrEvQ@mail.gmail.com>
 <20120710104722.GB14154@suse.de>
 <CAAmzW4NhRipDDqyNc3zYTx3fpsOVE6Cc6kc9X-L_p0iKZu7+jA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAAmzW4NhRipDDqyNc3zYTx3fpsOVE6Cc6kc9X-L_p0iKZu7+jA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: David Rientjes <rientjes@google.com>, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jul 11, 2012 at 12:24:41AM +0900, JoonSoo Kim wrote:
> > That would be functionally similar to your patch but it will preserve git
> > blame, churn less code and be harder to make mistakes with in the unlikely
> > event a third call to alloc_pages_direct_compact is ever added.
> 
> Your suggestion looks good.
> But, the size of page_alloc.o is more than before.
> 
> I test 3 approaches, vanilla, always_inline and
> wrapping(alloc_page_direct_compact which is your suggestion).
> In my environment (v3.5-rc5, gcc 4.6.3, x86_64), page_alloc.o shows
> below number.
> 
>                                          total, .text section, .text.unlikely
> page_alloc_vanilla.o:     93432,   0x510a,        0x243
> page_alloc_inline.o:       93336,   0x52ca,          0xa4
> page_alloc_wrapping.o: 93528,   0x515a,        0x238
> 
> Andrew said that inlining add only 26 bytes to .text of page_alloc.o,
> but in my system, need more bytes.
> Currently, I think this patch doesn't have obvious benefit, so I want
> to drop it.
> Any objections?
> 

No objections to dropping the patch. It was at worth looking at so thanks
for that.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
