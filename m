Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E10746B0010
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 09:10:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f16-v6so475873edq.18
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 06:10:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o8-v6si3988144edl.95.2018.06.22.06.10.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jun 2018 06:10:14 -0700 (PDT)
Date: Fri, 22 Jun 2018 15:10:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: dm bufio: Reduce dm_bufio_lock contention
Message-ID: <20180622131013.GA10465@dhcp22.suse.cz>
References: <20180615073201.GB24039@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806150724260.15022@file01.intranet.prod.int.rdu2.redhat.com>
 <20180615115547.GH24039@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806150832100.26650@file01.intranet.prod.int.rdu2.redhat.com>
 <20180615130925.GI24039@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806181003560.4201@file01.intranet.prod.int.rdu2.redhat.com>
 <20180619104312.GD13685@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806191228110.25656@file01.intranet.prod.int.rdu2.redhat.com>
 <20180622090151.GS10465@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806220828040.8072@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1806220828040.8072@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: jing xia <jing.xia.mail@gmail.com>, Mike Snitzer <snitzer@redhat.com>, agk@redhat.com, dm-devel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 22-06-18 08:44:52, Mikulas Patocka wrote:
> On Fri, 22 Jun 2018, Michal Hocko wrote:
[...]
> > Why? How are you going to audit all the callers that the behavior makes
> > sense and moreover how are you going to ensure that future usage will
> > still make sense. The more subtle side effects gfp flags have the harder
> > they are to maintain.
> 
> I did audit them - see the previous email in this thread: 
> https://www.redhat.com/archives/dm-devel/2018-June/thread.html

I do not see any mention about throttling expectations for those users.
You have focused only on the allocation failure fallback AFAIR
-- 
Michal Hocko
SUSE Labs
