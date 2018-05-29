Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id F0ECD6B000C
	for <linux-mm@kvack.org>; Tue, 29 May 2018 04:22:43 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id l187-v6so3681431pgl.6
        for <linux-mm@kvack.org>; Tue, 29 May 2018 01:22:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i6-v6si6111302pgt.470.2018.05.29.01.22.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 May 2018 01:22:43 -0700 (PDT)
Date: Tue, 29 May 2018 10:22:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] doc: document scope NOFS, NOIO APIs
Message-ID: <20180529082240.GP27180@dhcp22.suse.cz>
References: <20180424183536.GF30619@thunk.org>
 <20180524114341.1101-1-mhocko@kernel.org>
 <6c9df175-df6c-2531-b90c-318e4fff72bb@infradead.org>
 <20180525075217.GF11881@dhcp22.suse.cz>
 <7c5d8afb-563f-43fd-50ef-d532550983c7@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7c5d8afb-563f-43fd-50ef-d532550983c7@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <nborisov@suse.com>
Cc: Randy Dunlap <rdunlap@infradead.org>, Jonathan Corbet <corbet@lwn.net>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, "Darrick J. Wong" <darrick.wong@oracle.com>, David Sterba <dsterba@suse.cz>

On Mon 28-05-18 10:21:00, Nikolay Borisov wrote:
> 
> 
> On 25.05.2018 10:52, Michal Hocko wrote:
> > On Thu 24-05-18 09:37:18, Randy Dunlap wrote:
> >> On 05/24/2018 04:43 AM, Michal Hocko wrote:
> > [...]
> >>> +The traditional way to avoid this deadlock problem is to clear __GFP_FS
> >>> +resp. __GFP_IO (note the later implies clearing the first as well) in
> >>
> >>                             latter
> > 
> > ?
> > No I really meant that clearing __GFP_IO implies __GFP_FS clearing
> Sorry to barge in like that, but Randy is right.
> 
> <NIT WARNING>
> 
> 
> https://www.merriam-webster.com/dictionary/latter
> 
> " of, relating to, or being the second of two groups or things or the
> last of several groups or things referred to
> 
> </NIT WARNING>

Fixed
-- 
Michal Hocko
SUSE Labs
