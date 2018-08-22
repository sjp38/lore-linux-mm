Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7058C6B23A1
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 05:24:44 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x20-v6so656813eda.22
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 02:24:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t11-v6si1466488edt.159.2018.08.22.02.24.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 02:24:43 -0700 (PDT)
Date: Wed, 22 Aug 2018 11:24:40 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 0/2] fix for "pathological THP behavior"
Message-ID: <20180822092440.GH29735@dhcp22.suse.cz>
References: <20180820032204.9591-1-aarcange@redhat.com>
 <20180820115818.mmeayjkplux2z6im@kshutemo-mobl1>
 <20180820151905.GB13047@redhat.com>
 <6120e1b6-b4d2-96cb-2555-d8fab65c23c8@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6120e1b6-b4d2-96cb-2555-d8fab65c23c8@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>

On Tue 21-08-18 17:30:11, Vlastimil Babka wrote:
[...]
> Frankly, I would rather go with this option and assume that if someone
> explicitly wants THP's, they don't care about NUMA locality that much.

Yes. And if they do care enough to configure for heavier fault-in
treatment then they also can handle numa policy as well.

> (Note: I hate __GFP_THISNODE, it's an endless source of issues.)

Absolutely. It used to be a slab thing but then found an interesting
abuse elsewhere. Like here for the THP. I am pretty sure that the
intention was not to stick to a specific node but rather all local nodes
within the reclaim distance (or other unit to define that nodes are
sufficiently close).

> Trying to be clever about "is there still PAGE_SIZEd free memory in the
> local node" is imperfect anyway. If there isn't, is it because there's
> clean page cache that we can easily reclaim (so it would be worth
> staying local) or is it really exhausted? Watermark check won't tell...

Exactly.
-- 
Michal Hocko
SUSE Labs
