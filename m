Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2E5E26B1CB7
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 20:56:55 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id j13so234731oii.8
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 17:56:55 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g4si17453258otd.220.2018.11.19.17.56.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 17:56:54 -0800 (PST)
Date: Tue, 20 Nov 2018 09:56:44 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: Memory hotplug softlock issue
Message-ID: <20181120015644.GA5727@MiWiFi-R3L-srv>
References: <20181115143204.GV23831@dhcp22.suse.cz>
 <20181116012433.GU2653@MiWiFi-R3L-srv>
 <20181116091409.GD14706@dhcp22.suse.cz>
 <20181119105202.GE18471@MiWiFi-R3L-srv>
 <20181119124033.GJ22247@dhcp22.suse.cz>
 <20181119125121.GK22247@dhcp22.suse.cz>
 <20181119141016.GO22247@dhcp22.suse.cz>
 <20181119173312.GV22247@dhcp22.suse.cz>
 <alpine.LSU.2.11.1811191215290.15640@eggly.anvils>
 <20181119205907.GW22247@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181119205907.GW22247@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, pifang@redhat.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, Mel Gorman <mgorman@suse.de>

On 11/19/18 at 09:59pm, Michal Hocko wrote:
> On Mon 19-11-18 12:34:09, Hugh Dickins wrote:
> > I'm glad that I delayed, what I had then (migration_waitqueue instead
> > of using page_waitqueue) was not wrong, but what I've been using the
> > last couple of months is rather better (and can be put to use to solve
> > similar problems in collapsing pages on huge tmpfs. but we don't need
> > to get into that at this time): put_and_wait_on_page_locked().
> > 
> > What I have not yet done is verify it on latest kernel, and research
> > the interested Cc list (Linus and Tim Chen come immediately to mind),
> > and write the commit comment. I have some testing to do on the latest
> > kernel today, so I'll throw put_and_wait_on_page_locked() in too,
> > and post tomorrow I hope.
> 
> Cool, it seems that Baoquan has a reliable test case to trigger the
> pathological case.

Yes. I will test Hugh's patch.
