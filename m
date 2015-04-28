Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5D1B36B0038
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 07:38:25 -0400 (EDT)
Received: by wizk4 with SMTP id k4so136569911wiz.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 04:38:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b20si4079352wjx.55.2015.04.28.04.38.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Apr 2015 04:38:23 -0700 (PDT)
Date: Tue, 28 Apr 2015 12:38:20 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 11/13] mm: meminit: Free pages in large chunks where
 possible
Message-ID: <20150428113819.GL2449@suse.de>
References: <1429785196-7668-1-git-send-email-mgorman@suse.de>
 <1429785196-7668-12-git-send-email-mgorman@suse.de>
 <20150427154356.67e3d186b732a2c2b00e49cb@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150427154356.67e3d186b732a2c2b00e49cb@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, Apr 27, 2015 at 03:43:56PM -0700, Andrew Morton wrote:
> On Thu, 23 Apr 2015 11:33:14 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > Parallel struct page frees pages one at a time. Try free pages as single
> > large pages where possible.
> > 
> > ...
> >
> >  void __defermem_init deferred_init_memmap(int nid)
> 
> This function is gruesome in an 80-col display.  Even the code comments
> wrap, which is nuts.  Maybe hoist the contents of the outermost loop
> into a separate function, called for each zone?

I can do better than that because only the highest zone is deferred
in this version and the loop is no longer necessary. I should post a V4
before the end of my day that addresses your feedback.  It caused a lot of
conflicts and it'll be easier to replace the full series than try managing
incremental fixes.

Thanks Andrew.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
