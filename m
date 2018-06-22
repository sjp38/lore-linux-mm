Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1557F6B0003
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 14:47:02 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id d7-v6so5979066qth.21
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 11:47:02 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id g44-v6si4325104qtc.366.2018.06.22.11.46.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jun 2018 11:46:59 -0700 (PDT)
Date: Fri, 22 Jun 2018 14:46:58 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: dm bufio: Reduce dm_bufio_lock contention
In-Reply-To: <20180622131013.GA10465@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1806221445310.2717@file01.intranet.prod.int.rdu2.redhat.com>
References: <20180615073201.GB24039@dhcp22.suse.cz> <alpine.LRH.2.02.1806150724260.15022@file01.intranet.prod.int.rdu2.redhat.com> <20180615115547.GH24039@dhcp22.suse.cz> <alpine.LRH.2.02.1806150832100.26650@file01.intranet.prod.int.rdu2.redhat.com>
 <20180615130925.GI24039@dhcp22.suse.cz> <alpine.LRH.2.02.1806181003560.4201@file01.intranet.prod.int.rdu2.redhat.com> <20180619104312.GD13685@dhcp22.suse.cz> <alpine.LRH.2.02.1806191228110.25656@file01.intranet.prod.int.rdu2.redhat.com>
 <20180622090151.GS10465@dhcp22.suse.cz> <alpine.LRH.2.02.1806220828040.8072@file01.intranet.prod.int.rdu2.redhat.com> <20180622131013.GA10465@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: jing xia <jing.xia.mail@gmail.com>, Mike Snitzer <snitzer@redhat.com>, agk@redhat.com, dm-devel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On Fri, 22 Jun 2018, Michal Hocko wrote:

> On Fri 22-06-18 08:44:52, Mikulas Patocka wrote:
> > On Fri, 22 Jun 2018, Michal Hocko wrote:
> [...]
> > > Why? How are you going to audit all the callers that the behavior makes
> > > sense and moreover how are you going to ensure that future usage will
> > > still make sense. The more subtle side effects gfp flags have the harder
> > > they are to maintain.
> > 
> > I did audit them - see the previous email in this thread: 
> > https://www.redhat.com/archives/dm-devel/2018-June/thread.html
> 
> I do not see any mention about throttling expectations for those users.
> You have focused only on the allocation failure fallback AFAIR

How should the callers be analyzed with respect to throttling?

Mikulas
