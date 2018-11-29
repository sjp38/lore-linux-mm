Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A5BCF6B53B2
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 12:17:20 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id q8so1387730edd.8
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 09:17:20 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p10si1186589edh.181.2018.11.29.09.17.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 09:17:19 -0800 (PST)
Date: Thu, 29 Nov 2018 18:17:17 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v3 1/2] mm, sparse: drop pgdat_resize_lock in
 sparse_add/remove_one_section()
Message-ID: <20181129171717.GY6923@dhcp22.suse.cz>
References: <20181128091243.19249-1-richard.weiyang@gmail.com>
 <20181129155316.8174-1-richard.weiyang@gmail.com>
 <d67e3edd-5a93-c133-3b3c-d3833ed27fd5@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d67e3edd-5a93-c133-3b3c-d3833ed27fd5@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, osalvador@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org

On Thu 29-11-18 17:06:15, David Hildenbrand wrote:
> I suggest adding what you just found out to
[...]
> Documentation/admin-guide/mm/memory-hotplug.rst "Locking Internals".
> Maybe a new subsection for mem_hotplug_lock. And eventually also
> pgdat_resize_lock.

That would be really great! I guess I have suggested something like that
to Oscar already and he provided a highlevel overview.
-- 
Michal Hocko
SUSE Labs
