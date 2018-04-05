Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 56ED46B0007
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 12:03:20 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x15so1601258wmc.7
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 09:03:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a18si4060437wri.425.2018.04.05.09.03.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Apr 2018 09:03:18 -0700 (PDT)
Date: Thu, 5 Apr 2018 18:03:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm: consider non-anonymous thp as unmovable page
Message-ID: <20180405160317.GP6312@dhcp22.suse.cz>
References: <20180403075928.GC5501@dhcp22.suse.cz>
 <20180403082405.GA23809@hori1.linux.bs1.fc.nec.co.jp>
 <20180403083451.GG5501@dhcp22.suse.cz>
 <20180403105411.hknofkbn6rzs26oz@node.shutemov.name>
 <20180405085927.GC6312@dhcp22.suse.cz>
 <20180405122838.6a6b35psizem4tcy@node.shutemov.name>
 <20180405124830.GJ6312@dhcp22.suse.cz>
 <20180405134045.7axuun6d7ufobzj4@node.shutemov.name>
 <20180405150547.GN6312@dhcp22.suse.cz>
 <20180405155551.wchleyaf4rxooj6m@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405155551.wchleyaf4rxooj6m@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu 05-04-18 18:55:51, Kirill A. Shutemov wrote:
> On Thu, Apr 05, 2018 at 05:05:47PM +0200, Michal Hocko wrote:
> > On Thu 05-04-18 16:40:45, Kirill A. Shutemov wrote:
> > > On Thu, Apr 05, 2018 at 02:48:30PM +0200, Michal Hocko wrote:
> > [...]
> > > > RIght, I confused the two. What is the proper layer to fix that then?
> > > > rmap_walk_file?
> > > 
> > > Maybe something like this? Totally untested.
> > 
> > This looks way too complex. Why cannot we simply split THP page cache
> > during migration?
> 
> This way we unify the codepath for archictures that don't support THP
> migration and shmem THP.

But why? There shouldn't be really nothing to prevent THP (anon or
shemem) to be migratable. If we cannot migrate it at once we can always
split it. So why should we add another thp specific handling all over
the place?
-- 
Michal Hocko
SUSE Labs
