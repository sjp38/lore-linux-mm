Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id ACAB46B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 17:18:40 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id hz20so268045lab.41
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 14:18:39 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c2si4645886lac.0.2014.08.13.14.18.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 Aug 2014 14:18:38 -0700 (PDT)
Date: Wed, 13 Aug 2014 22:18:34 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: Actually clear pmd_numa before invalidating
Message-ID: <20140813211834.GJ7970@suse.de>
References: <1407943707-5547-1-git-send-email-matthew.r.wilcox@intel.com>
 <20140813125951.7619f8e908eefb99c40827c4@linux-foundation.org>
 <100D68C7BA14664A8938383216E40DE0407D0CA2@FMSMSX114.amr.corp.intel.com>
 <20140813131241.3ced5ccaeec24fcd378a1ef6@linux-foundation.org>
 <100D68C7BA14664A8938383216E40DE0407D0CE2@FMSMSX114.amr.corp.intel.com>
 <20140813132333.92f2ade49867acbfb9ed696b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140813132333.92f2ade49867acbfb9ed696b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>

On Wed, Aug 13, 2014 at 01:23:33PM -0700, Andrew Morton wrote:
> On Wed, 13 Aug 2014 20:16:31 +0000 "Wilcox, Matthew R" <matthew.r.wilcox@intel.com> wrote:
> 
> > I am quite shockingly ignorant of the MM code.  While looking at this
> > function to figure out how/whether to use it, I noticed the bug, and
> > sent a patch.  I assumed the gibberish in the changelog meant something
> > important to people who actually understand this part of the kernel :-)
> 
> Fair enough ;)  Mel?

The issue was theoritical in nature. The patch was meant to guarantee
the PTE was in a known state. As I cannot think of a way it could
trigger a bug I wouldn't consider it -stable material but Matthew's
patch is still doing the expected thing.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
