Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1716B71D0
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 02:57:51 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h10-v6so2195056eda.9
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 23:57:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b56-v6si1081303edb.386.2018.09.04.23.57.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 23:57:50 -0700 (PDT)
Date: Wed, 5 Sep 2018 08:57:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 1/2] mm: migration: fix migration of huge PMD shared
 pages
Message-ID: <20180905065746.GY14951@dhcp22.suse.cz>
References: <20180829183906.GF10223@dhcp22.suse.cz>
 <20180829211106.GC3784@redhat.com>
 <20180830105616.GD2656@dhcp22.suse.cz>
 <20180830140825.GA3529@redhat.com>
 <20180830161800.GJ2656@dhcp22.suse.cz>
 <20180830165751.GD3529@redhat.com>
 <e0c0c966-6706-4ca2-4077-e79322756a9b@oracle.com>
 <20180830183944.GE3529@redhat.com>
 <20180903055654.GA14951@dhcp22.suse.cz>
 <20180904140035.GA3526@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180904140035.GA3526@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, linux-rdma@vger.kernel.org, Matan Barak <matanb@mellanox.com>, Leon Romanovsky <leonro@mellanox.com>, Dimitri Sivanich <sivanich@sgi.com>

On Tue 04-09-18 10:00:36, Jerome Glisse wrote:
> On Mon, Sep 03, 2018 at 07:56:54AM +0200, Michal Hocko wrote:
[...]
> > And THP migration is still a problem with 4.4 AFAICS. All other cases
> > simply split the huge page but THP migration keeps it in one piece and
> > as such it is theoretically broken as you have explained. So I would
> > stick with what I posted with some more clarifications in the changelog
> > if you think it is appropriate (suggestions welcome).
> 
> Reading code there is no THP migration in 4.4 only huge tlb migration.

Meh, you are right. For some reason I misread unmap_and_move_huge_page
to be also for THP. Sorry for the conusion. My fault!

Then it would be indeed safer to use your backport.
-- 
Michal Hocko
SUSE Labs
