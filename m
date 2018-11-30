Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3DC356B5790
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 04:52:34 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id k58so2557295eda.20
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 01:52:34 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a12si2262132edk.106.2018.11.30.01.52.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 01:52:33 -0800 (PST)
Date: Fri, 30 Nov 2018 10:52:30 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v3 1/2] mm, sparse: drop pgdat_resize_lock in
 sparse_add/remove_one_section()
Message-ID: <20181130095230.GG6923@dhcp22.suse.cz>
References: <20181128091243.19249-1-richard.weiyang@gmail.com>
 <20181129155316.8174-1-richard.weiyang@gmail.com>
 <d67e3edd-5a93-c133-3b3c-d3833ed27fd5@redhat.com>
 <20181130042815.t44nroyqcqa3tpgv@master>
 <c1eab65f-b7b9-9a38-1ac5-8a23dbcb249f@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c1eab65f-b7b9-9a38-1ac5-8a23dbcb249f@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@suse.de
Cc: Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, David Hildenbrand <david@redhat.com>, akpm@linux-foundation.org, linux-mm@kvack.org

On Fri 30-11-18 10:19:13, David Hildenbrand wrote:
> >> I suggest adding what you just found out to
> >> Documentation/admin-guide/mm/memory-hotplug.rst "Locking Internals".
> >> Maybe a new subsection for mem_hotplug_lock. And eventually also
> >> pgdat_resize_lock.
> > 
> > Well, I am not good at document writting. Below is my first trial.  Look
> > forward your comments.
> 
> I'll have a look, maybe also Oscar and Michal can have a look. I guess
> we don't have to cover all now, we can add more details as we discover them.

Oscar, didn't you have something already?
-- 
Michal Hocko
SUSE Labs
