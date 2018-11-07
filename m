Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6D3DB6B04C7
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 02:55:44 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id 33-v6so2980075eds.16
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 23:55:44 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c41-v6si155794ede.71.2018.11.06.23.55.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 23:55:43 -0800 (PST)
Message-ID: <1541577326.3089.2.camel@suse.de>
Subject: Re: [PATCH] mm, memory_hotplug: check zone_movable in
 has_unmovable_pages
From: osalvador <osalvador@suse.de>
Date: Wed, 07 Nov 2018 08:55:26 +0100
In-Reply-To: <20181107073548.GU27423@dhcp22.suse.cz>
References: <20181106095524.14629-1-mhocko@kernel.org>
	 <20181106203518.GC9042@350D> <20181107073548.GU27423@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Balbir Singh <bsingharora@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 2018-11-07 at 08:35 +0100, Michal Hocko wrote:
> On Wed 07-11-18 07:35:18, Balbir Singh wrote:
> > The check seems to be quite aggressive and in a loop that iterates
> > pages, but has nothing to do with the page, did you mean to make
> > the check
> > 
> > zone_idx(page_zone(page)) == ZONE_MOVABLE
> 
> Does it make any difference? Can we actually encounter a page from a
> different zone here?

AFAIK, test_pages_in_a_zone() called from offline_pages() should ensure
that the range belongs to a unique zone, so we should not encounter
pages from other zones there, right?

---
Oscar
Suse L3
