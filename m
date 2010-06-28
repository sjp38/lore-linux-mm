Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 563FB6B01B2
	for <linux-mm@kvack.org>; Sun, 27 Jun 2010 23:31:06 -0400 (EDT)
Date: Mon, 28 Jun 2010 13:30:54 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: Slow vmalloc in 2.6.35-rc3
Message-ID: <20100628033054.GL29809@laptop>
References: <4C232324.7070305@redhat.com>
 <20100624151427.GH10441@laptop>
 <4C271736.5010102@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C271736.5010102@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, KVM list <kvm@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 27, 2010 at 12:17:42PM +0300, Avi Kivity wrote:
> On 06/24/2010 06:14 PM, Nick Piggin wrote:
> >On Thu, Jun 24, 2010 at 12:19:32PM +0300, Avi Kivity wrote:
> >>I see really slow vmalloc performance on 2.6.35-rc3:
> >Can you try this patch?
> >http://userweb.kernel.org/~akpm/mmotm/broken-out/mm-vmap-area-cache.patch
> 
> The patch completely eliminates the problem.

Thanks for testing. Andrew the patch changelog can be updated.  Avi and
Steven didn't give me numbers but it solves both their performance
regressions, so I would say it is ready for merging.

Thanks,
Nick


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
