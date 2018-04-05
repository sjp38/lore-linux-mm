Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 953606B0007
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 11:56:35 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id b9so8201347wrj.15
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 08:56:35 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i2sor4532939edb.46.2018.04.05.08.56.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Apr 2018 08:56:34 -0700 (PDT)
Date: Thu, 5 Apr 2018 18:55:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v1] mm: consider non-anonymous thp as unmovable page
Message-ID: <20180405155551.wchleyaf4rxooj6m@node.shutemov.name>
References: <1522730788-24530-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180403075928.GC5501@dhcp22.suse.cz>
 <20180403082405.GA23809@hori1.linux.bs1.fc.nec.co.jp>
 <20180403083451.GG5501@dhcp22.suse.cz>
 <20180403105411.hknofkbn6rzs26oz@node.shutemov.name>
 <20180405085927.GC6312@dhcp22.suse.cz>
 <20180405122838.6a6b35psizem4tcy@node.shutemov.name>
 <20180405124830.GJ6312@dhcp22.suse.cz>
 <20180405134045.7axuun6d7ufobzj4@node.shutemov.name>
 <20180405150547.GN6312@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405150547.GN6312@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Apr 05, 2018 at 05:05:47PM +0200, Michal Hocko wrote:
> On Thu 05-04-18 16:40:45, Kirill A. Shutemov wrote:
> > On Thu, Apr 05, 2018 at 02:48:30PM +0200, Michal Hocko wrote:
> [...]
> > > RIght, I confused the two. What is the proper layer to fix that then?
> > > rmap_walk_file?
> > 
> > Maybe something like this? Totally untested.
> 
> This looks way too complex. Why cannot we simply split THP page cache
> during migration?

This way we unify the codepath for archictures that don't support THP
migration and shmem THP.

-- 
 Kirill A. Shutemov
