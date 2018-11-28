Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D77DF6B4CF4
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 07:34:09 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id v4so12094101edm.18
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 04:34:09 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g18-v6si3311504eja.148.2018.11.28.04.34.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 04:34:08 -0800 (PST)
Date: Wed, 28 Nov 2018 13:34:06 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, sparse: drop pgdat_resize_lock in
 sparse_add/remove_one_section()
Message-ID: <20181128123406.GK6923@dhcp22.suse.cz>
References: <20181127023630.9066-1-richard.weiyang@gmail.com>
 <20181127062514.GJ12455@dhcp22.suse.cz>
 <3356e00d-9135-12ef-a53f-49d815b8fbfc@intel.com>
 <20181128010112.5tv7tpe3qeplzy6d@master>
 <20181128084729.jozab2gaej5vh7ig@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181128084729.jozab2gaej5vh7ig@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Dave Hansen <dave.hansen@intel.com>, akpm@linux-foundation.org, linux-mm@kvack.org

On Wed 28-11-18 08:47:29, Wei Yang wrote:
[...]
> The mem_section[root] still has a chance to face the contention here.

_If_ that is really the case then we need a dedicated lock rather than
rely on pgdat which doesn't even make sense for sparsemem internal.

-- 
Michal Hocko
SUSE Labs
