Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 25D316B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 05:56:02 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a4so32845372lfa.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 02:56:02 -0700 (PDT)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id d7si11049526wja.108.2016.06.17.02.56.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 02:56:00 -0700 (PDT)
Received: by mail-wm0-f51.google.com with SMTP id v199so223392662wmv.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 02:56:00 -0700 (PDT)
Date: Fri, 17 Jun 2016 11:55:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 6/7] mm/page_owner: use stackdepot to store stacktrace
Message-ID: <20160617095559.GC21670@dhcp22.suse.cz>
References: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1464230275-25791-6-git-send-email-iamjoonsoo.kim@lge.com>
 <20160606135604.GJ11895@dhcp22.suse.cz>
 <20160617072525.GA810@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160617072525.GA810@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 17-06-16 16:25:26, Joonsoo Kim wrote:
> On Mon, Jun 06, 2016 at 03:56:04PM +0200, Michal Hocko wrote:
[...]
> > I still have troubles to understand your numbers
> > 
> > > static allocation:
> > > 92274688 bytes -> 25165824 bytes
> > 
> > I assume that the first numbers refers to the static allocation for the
> > given amount of memory while the second one is the dynamic after the
> > boot, right?
> 
> No, first number refers to the static allocation before the patch and
> second one is for after the patch.

I guess we are both talking about the same thing in different words. All
the allocations are static before the patch while all are dynamic after
the patch. Your boot example just shows how much dynamic memory gets
allocated during your boot. This will depend on the particular
configuration but it will at least give a picture what the savings might
be.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
