Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 60B806B0071
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 10:01:37 -0500 (EST)
Date: Wed, 1 Dec 2010 09:01:32 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages
In-Reply-To: <20101130142509.4f49d452.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1012010859020.2849@router.home>
References: <20101130101126.17475.18729.stgit@localhost6.localdomain6> <20101130101602.17475.32611.stgit@localhost6.localdomain6> <20101130142509.4f49d452.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm <kvm@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010, Andrew Morton wrote:

> > +#define UNMAPPED_PAGE_RATIO 16
>
> Well.  Giving 16 a name didn't really clarify anything.  Attentive
> readers will want to know what this does, why 16 was chosen and what
> the effects of changing it will be.

The meaning is analoguous to the other zone reclaim ratio. But yes it
should be justified and defined.

> > Reviewed-by: Christoph Lameter <cl@linux.com>
>
> So you're OK with shoving all this flotsam into 100,000,000 cellphones?
> This was a pretty outrageous patchset!

This is a feature that has been requested over and over for years. Using
/proc/vm/drop_caches for fixing situations where one simply has too many
page cache pages is not so much fun in the long run.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
