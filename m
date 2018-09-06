Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC60E6B79CA
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 13:08:17 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id o27-v6so6140250pfj.6
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 10:08:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p2-v6si5695760pfd.76.2018.09.06.10.08.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 10:08:15 -0700 (PDT)
Date: Thu, 6 Sep 2018 19:08:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm: Move page struct poisoning to
 CONFIG_DEBUG_VM_PAGE_INIT_POISON
Message-ID: <20180906170813.GF14951@dhcp22.suse.cz>
References: <20180905211041.3286.19083.stgit@localhost.localdomain>
 <20180905211328.3286.71674.stgit@localhost.localdomain>
 <20180906054735.GJ14951@dhcp22.suse.cz>
 <0c1c36f7-f45a-8fe9-dd52-0f60b42064a9@intel.com>
 <20180906151336.GD14951@dhcp22.suse.cz>
 <33f39b37-9567-88a8-097d-a63df04c7732@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <33f39b37-9567-88a8-097d-a63df04c7732@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, alexander.h.duyck@intel.com, pavel.tatashin@microsoft.com, akpm@linux-foundation.org, mingo@kernel.org, kirill.shutemov@linux.intel.com

On Thu 06-09-18 09:09:46, Dave Hansen wrote:
[...]
> Has anyone ever seen a single in-the-wild report from this mechanism?

Yes. See the list from Pavel. And I wouldn't push for it otherwise.
There are some questionable asserts with an overhead which is not
directly visible but it just adds up. This is different that it is one
time boot rare thing.

Anyway, I guess I have put all my arguments on the table. I will leave
the decision to you guys. If there is a strong concensus about a config
option, then I can live with that and will enable it.

-- 
Michal Hocko
SUSE Labs
