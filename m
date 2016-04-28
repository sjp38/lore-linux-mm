Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1456B007E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 12:00:24 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 68so68212669lfq.2
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 09:00:24 -0700 (PDT)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id c191si16449878wme.44.2016.04.28.09.00.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 09:00:22 -0700 (PDT)
Received: by mail-wm0-f42.google.com with SMTP id n129so71125180wmn.1
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 09:00:22 -0700 (PDT)
Date: Thu, 28 Apr 2016 18:00:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 19/20] md: simplify free_params for kmalloc vs vmalloc
 fallback
Message-ID: <20160428160021.GN31489@dhcp22.suse.cz>
References: <1461849846-27209-1-git-send-email-mhocko@kernel.org>
 <1461849846-27209-20-git-send-email-mhocko@kernel.org>
 <20160428153730.GA14570@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160428153730.GA14570@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <snitzer@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mikulas Patocka <mpatocka@redhat.com>, Shaohua Li <shli@kernel.org>

On Thu 28-04-16 11:37:31, Mike Snitzer wrote:
> On Thu, Apr 28 2016 at  9:24am -0400,
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Use kvfree rather than DM_PARAMS_[KV]MALLOC specific param flags.
> > 
> > Cc: Shaohua Li <shli@kernel.org>
> > Cc: Mikulas Patocka <mpatocka@redhat.com>
> > Cc: dm-devel@redhat.com
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Nack, seriously, this is the 3rd time this patch has been attempted.
> Did you actually test the change?  It'll crash very quickly, see:
> 
> https://www.redhat.com/archives/dm-devel/2016-April/msg00103.html

You are right! My bad I should have checked the other callers!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
