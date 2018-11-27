Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9C0D96B46AD
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 03:00:38 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id k58so10429052eda.20
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 00:00:38 -0800 (PST)
Date: Tue, 27 Nov 2018 09:00:35 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, sparse: drop pgdat_resize_lock in
 sparse_add/remove_one_section()
Message-ID: <20181127080035.GO12455@dhcp22.suse.cz>
References: <20181127023630.9066-1-richard.weiyang@gmail.com>
 <20181127062514.GJ12455@dhcp22.suse.cz>
 <3356e00d-9135-12ef-a53f-49d815b8fbfc@intel.com>
 <4fe3f8203a35ea01c9e0ed87c361465e@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4fe3f8203a35ea01c9e0ed87c361465e@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@suse.de
Cc: Dave Hansen <dave.hansen@intel.com>, Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, owner-linux-mm@kvack.org

[I am mostly offline and will be so tomorrow as well]

On Tue 27-11-18 08:52:14, osalvador@suse.de wrote:
[...]
> So, although removing the lock here is pretty straightforward, it does not
> really get us closer to that goal IMHO, if that is what we want to do in the
> end.

But it doesn't get us further either, right? This patch shouldn't make
any plan for range locking any worse. Both adding and removing a sparse
section is pfn range defined unless I am missing something.
-- 
Michal Hocko
SUSE Labs
