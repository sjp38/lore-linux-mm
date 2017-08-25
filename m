Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6A84F6810B7
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 04:04:46 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 136so1734718wmm.11
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 01:04:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 138si805695wmf.127.2017.08.25.01.04.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 Aug 2017 01:04:45 -0700 (PDT)
Date: Fri, 25 Aug 2017 10:04:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] treewide: remove GFP_TEMPORARY allocation flag
Message-ID: <20170825080442.GF25498@dhcp22.suse.cz>
References: <20170728091904.14627-1-mhocko@kernel.org>
 <20170823175709.GA22743@xo-6d-61-c0.localdomain>
 <20170825063545.GA25498@dhcp22.suse.cz>
 <20170825072818.GA15494@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170825072818.GA15494@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Neil Brown <neilb@suse.de>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 25-08-17 09:28:19, Pavel Machek wrote:
> On Fri 2017-08-25 08:35:46, Michal Hocko wrote:
> > On Wed 23-08-17 19:57:09, Pavel Machek wrote:
[...]
> > > Dunno. < 1msec probably is temporary, 1 hour probably is not. If it causes
> > > problems, can you just #define GFP_TEMPORARY GFP_KERNEL ? Treewide replace,
> > > and then starting again goes not look attractive to me.
> > 
> > I do not think we want a highlevel GFP_TEMPORARY without any meaning.
> > This just supports spreading the flag usage without a clear semantic
> > and it will lead to even bigger mess. Once we can actually define what
> > the flag means we can also add its users based on that new semantic.
> 
> It has real meaning.

Which is?
 
> You can define more exact meaning, and then adjust the usage. But
> there's no need to do treewide replacement...

I have checked most of them and except for the initially added onces the
large portion where added without a good reasons or even break an
intuitive meaning by taking locks.

Seriously, if we need a short term semantic it should be clearly defined
first.

Is there any specific case why you think this patch is in a wrong
direction? E.g. a measurable regression?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
