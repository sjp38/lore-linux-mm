Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 01E536B000A
	for <linux-mm@kvack.org>; Thu, 24 May 2018 10:47:11 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k18-v6so1601098wrm.6
        for <linux-mm@kvack.org>; Thu, 24 May 2018 07:47:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l13-v6si495698edj.379.2018.05.24.07.47.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 May 2018 07:47:09 -0700 (PDT)
Date: Thu, 24 May 2018 16:47:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] doc: document scope NOFS, NOIO APIs
Message-ID: <20180524144708.GL20441@dhcp22.suse.cz>
References: <20180424183536.GF30619@thunk.org>
 <20180524114341.1101-1-mhocko@kernel.org>
 <CALvZod6CmkNgkYkSchFXsPefnuNUDjOEhPXtEUOJaeuSiXCUKg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod6CmkNgkYkSchFXsPefnuNUDjOEhPXtEUOJaeuSiXCUKg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Jonathan Corbet <corbet@lwn.net>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, David Sterba <dsterba@suse.cz>

On Thu 24-05-18 07:33:39, Shakeel Butt wrote:
> On Thu, May 24, 2018 at 4:43 AM, Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > +The traditional way to avoid this deadlock problem is to clear __GFP_FS
> > +resp. __GFP_IO (note the later implies clearing the first as well) in
> 
> Is resp. == respectively? Why not use the full word (here and below)?

yes. Because I was lazy ;)

-- 
Michal Hocko
SUSE Labs
