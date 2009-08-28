Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2A73A6B00BB
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 09:43:03 -0400 (EDT)
Received: by fxm18 with SMTP id 18so1603713fxm.38
        for <linux-mm@kvack.org>; Fri, 28 Aug 2009 06:43:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090828133631.GF5054@csn.ul.ie>
References: <1251449067-3109-1-git-send-email-mel@csn.ul.ie>
	 <1251449067-3109-3-git-send-email-mel@csn.ul.ie>
	 <84144f020908280516y6473a531n3f11f3e86251eba4@mail.gmail.com>
	 <20090828125719.GE5054@csn.ul.ie>
	 <1251464564.8514.3.camel@penberg-laptop>
	 <20090828133631.GF5054@csn.ul.ie>
Date: Fri, 28 Aug 2009 16:43:05 +0300
Message-ID: <84144f020908280643h49799b94g270090f22c7cf5e0@mail.gmail.com>
Subject: Re: [PATCH 2/2] page-allocator: Maintain rolling count of pages to
	free from the PCP
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 28, 2009 at 4:36 PM, Mel Gorman<mel@csn.ul.ie> wrote:
> This is PCPU draining. The flags are already clear of any values of interest
> and the order is always 0. I can follow up a fix-patch that reverses it just
> in case but I don't think it makes a major difference?

Aha, OK. Probably not worth it then.

                             Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
