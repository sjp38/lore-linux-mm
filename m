Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D26A86B6DD6
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 03:53:18 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id o21so7923388edq.4
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 00:53:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u13-v6sor4178500ejt.19.2018.12.04.00.53.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 00:53:17 -0800 (PST)
Date: Tue, 4 Dec 2018 08:53:15 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v3 1/2] mm, sparse: drop pgdat_resize_lock in
 sparse_add/remove_one_section()
Message-ID: <20181204085315.uhgmhd37n5agnvfb@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181128091243.19249-1-richard.weiyang@gmail.com>
 <20181129155316.8174-1-richard.weiyang@gmail.com>
 <d67e3edd-5a93-c133-3b3c-d3833ed27fd5@redhat.com>
 <20181130042815.t44nroyqcqa3tpgv@master>
 <c1eab65f-b7b9-9a38-1ac5-8a23dbcb249f@redhat.com>
 <20181130095230.GG6923@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181130095230.GG6923@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: osalvador@suse.de, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, David Hildenbrand <david@redhat.com>, akpm@linux-foundation.org, linux-mm@kvack.org

On Fri, Nov 30, 2018 at 10:52:30AM +0100, Michal Hocko wrote:
>On Fri 30-11-18 10:19:13, David Hildenbrand wrote:
>> >> I suggest adding what you just found out to
>> >> Documentation/admin-guide/mm/memory-hotplug.rst "Locking Internals".
>> >> Maybe a new subsection for mem_hotplug_lock. And eventually also
>> >> pgdat_resize_lock.
>> > 
>> > Well, I am not good at document writting. Below is my first trial.  Look
>> > forward your comments.
>> 
>> I'll have a look, maybe also Oscar and Michal can have a look. I guess
>> we don't have to cover all now, we can add more details as we discover them.
>
>Oscar, didn't you have something already?

Since we prefer to address the document in a separate patch, I will send
out v4 with changes suggested from Michal and David first.

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
