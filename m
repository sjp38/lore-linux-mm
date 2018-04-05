Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3A06B0006
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 11:05:50 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id h14so4246390wre.6
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 08:05:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l3si1327246wrf.450.2018.04.05.08.05.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Apr 2018 08:05:49 -0700 (PDT)
Date: Thu, 5 Apr 2018 17:05:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm: consider non-anonymous thp as unmovable page
Message-ID: <20180405150547.GN6312@dhcp22.suse.cz>
References: <1522730788-24530-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180403075928.GC5501@dhcp22.suse.cz>
 <20180403082405.GA23809@hori1.linux.bs1.fc.nec.co.jp>
 <20180403083451.GG5501@dhcp22.suse.cz>
 <20180403105411.hknofkbn6rzs26oz@node.shutemov.name>
 <20180405085927.GC6312@dhcp22.suse.cz>
 <20180405122838.6a6b35psizem4tcy@node.shutemov.name>
 <20180405124830.GJ6312@dhcp22.suse.cz>
 <20180405134045.7axuun6d7ufobzj4@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405134045.7axuun6d7ufobzj4@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu 05-04-18 16:40:45, Kirill A. Shutemov wrote:
> On Thu, Apr 05, 2018 at 02:48:30PM +0200, Michal Hocko wrote:
[...]
> > RIght, I confused the two. What is the proper layer to fix that then?
> > rmap_walk_file?
> 
> Maybe something like this? Totally untested.

This looks way too complex. Why cannot we simply split THP page cache
during migration?
-- 
Michal Hocko
SUSE Labs
