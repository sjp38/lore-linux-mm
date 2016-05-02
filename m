Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3E6AB6B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 03:31:15 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y84so135503485lfc.3
        for <linux-mm@kvack.org>; Mon, 02 May 2016 00:31:15 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id pd2si32584797wjb.233.2016.05.02.00.31.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 00:31:13 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id w143so15875168wmw.3
        for <linux-mm@kvack.org>; Mon, 02 May 2016 00:31:13 -0700 (PDT)
Date: Mon, 2 May 2016 09:31:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 17/20] dm: get rid of superfluous gfp flags
Message-ID: <20160502073111.GA25265@dhcp22.suse.cz>
References: <1461849846-27209-1-git-send-email-mhocko@kernel.org>
 <1461849846-27209-18-git-send-email-mhocko@kernel.org>
 <20160429185451.GA21865@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160429185451.GA21865@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <snitzer@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mikulas Patocka <mpatocka@redhat.com>, Shaohua Li <shli@kernel.org>

On Fri 29-04-16 14:54:52, Mike Snitzer wrote:
> On Thu, Apr 28 2016 at  9:24am -0400,
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > copy_params seems to be little bit confused about which allocation flags
> > to use. It enforces GFP_NOIO even though it uses
> > memalloc_noio_{save,restore} which enforces GFP_NOIO at the page
> > allocator level automatically (via memalloc_noio_flags). It also
> > uses __GFP_REPEAT for the __vmalloc request which doesn't make much
> > sense either because vmalloc doesn't rely on costly high order
> > allocations. Let's just drop the __GFP_REPEAT and leave the further
> > cleanup to later changes.
> > 
> > Cc: Shaohua Li <shli@kernel.org>
> > Cc: Mikulas Patocka <mpatocka@redhat.com>
> > Cc: dm-devel@redhat.com
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> I've taken this patch for 4.7 but editted the header, see:
> https://git.kernel.org/cgit/linux/kernel/git/device-mapper/linux-dm.git/commit/?h=dm-4.7&id=0222c76e96163355620224625c1cd80991086dc7

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
