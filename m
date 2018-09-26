Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 56AF88E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 04:17:12 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g11-v6so840777edi.8
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 01:17:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d11-v6si7941655edr.307.2018.09.26.01.17.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 01:17:11 -0700 (PDT)
Date: Wed, 26 Sep 2018 10:17:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2 -mm] mm: brk: dwongrade mmap_sem to read when
 shrinking
Message-ID: <20180926081708.GG6278@dhcp22.suse.cz>
References: <1537922816-108051-1-git-send-email-yang.shi@linux.alibaba.com>
 <1537922816-108051-2-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1537922816-108051-2-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: kirill@shutemov.name, willy@infradead.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 26-09-18 08:46:56, Yang Shi wrote:
> brk might be used to shinrk memory mapping too. Use __do_munmap() to
> shrink mapping with downgrading mmap_sem to read.

same comment wrt the changelog as for the previous patch.
-- 
Michal Hocko
SUSE Labs
