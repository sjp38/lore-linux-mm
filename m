Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C70A56B0003
	for <linux-mm@kvack.org>; Fri, 25 May 2018 03:52:20 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k18-v6so3501616wrm.6
        for <linux-mm@kvack.org>; Fri, 25 May 2018 00:52:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a8-v6si1191516edf.331.2018.05.25.00.52.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 May 2018 00:52:18 -0700 (PDT)
Date: Fri, 25 May 2018 09:52:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] doc: document scope NOFS, NOIO APIs
Message-ID: <20180525075217.GF11881@dhcp22.suse.cz>
References: <20180424183536.GF30619@thunk.org>
 <20180524114341.1101-1-mhocko@kernel.org>
 <6c9df175-df6c-2531-b90c-318e4fff72bb@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6c9df175-df6c-2531-b90c-318e4fff72bb@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Jonathan Corbet <corbet@lwn.net>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, "Darrick J. Wong" <darrick.wong@oracle.com>, David Sterba <dsterba@suse.cz>

On Thu 24-05-18 09:37:18, Randy Dunlap wrote:
> On 05/24/2018 04:43 AM, Michal Hocko wrote:
[...]
> > +The traditional way to avoid this deadlock problem is to clear __GFP_FS
> > +resp. __GFP_IO (note the later implies clearing the first as well) in
> 
>                             latter

?
No I really meant that clearing __GFP_IO implies __GFP_FS clearing
-- 
Michal Hocko
SUSE Labs
