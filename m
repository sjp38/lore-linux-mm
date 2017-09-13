Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A4B0E6B0253
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 07:18:47 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q76so25053570pfq.5
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 04:18:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 69si10344651pla.682.2017.09.13.04.18.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Sep 2017 04:18:46 -0700 (PDT)
Date: Wed, 13 Sep 2017 13:18:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memblock.c: make the index explicit argument of
 for_each_memblock_type
Message-ID: <20170913111843.2kt344k7pmcmm2ed@dhcp22.suse.cz>
References: <20170913090606.16412-1-gi-oh.kim@profitbricks.com>
 <20170913105539.ijfwfrfbn3bici6g@dhcp22.suse.cz>
 <CAJX1Ytb+vFc3p3j8v9_jtMXT3UNVawQAMi4KeQ0FFHDJ7BP4WA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJX1Ytb+vFc3p3j8v9_jtMXT3UNVawQAMi4KeQ0FFHDJ7BP4WA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gi-Oh Kim <gi-oh.kim@profitbricks.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed 13-09-17 13:05:02, Gi-Oh Kim wrote:
> On Wed, Sep 13, 2017 at 12:55 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Wed 13-09-17 11:06:06, Gioh Kim wrote:
> >> for_each_memblock_type macro function uses idx variable that is
> >> the local variable of caller. This patch makes for_each_memblock_type
> >> use only its own arguments.
> >
> > strictly speaking this changelog doesn't explain _why_ the original code
> > is wrong/suboptimal and why you are changing that. I would use the
> > folloging
> >
> > "
> > for_each_memblock_type macro function relies on idx variable defined in
> > the caller context. Silent macro arguments are almost always wrong thing
> > to do. They make code harder to read and easier to get wrong. Let's
> > use an explicit iterator parameter for for_each_memblock_type and make
> > the code more obious. This patch is a mere cleanup and it shouldn't
> > introduce any functional change.
> > "
> 
> Absolutely this changelog is better.
> Should I send the patch with your changelog again?
> Or could you just replace my changelog with yours?

Please repost and make sure to CC Andrew Morton so that he can take the
patch.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
