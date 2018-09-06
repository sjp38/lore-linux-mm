Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 711066B78C6
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 08:35:41 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c16-v6so3625056edc.21
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 05:35:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d29-v6si4143943edb.244.2018.09.06.05.35.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 05:35:40 -0700 (PDT)
Date: Thu, 6 Sep 2018 14:35:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH V2 1/4] mm: Export alloc_migrate_huge_page
Message-ID: <20180906123539.GV14951@dhcp22.suse.cz>
References: <20180906054342.25094-1-aneesh.kumar@linux.ibm.com>
 <20180906123111.GC26069@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180906123111.GC26069@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: akpm@linux-foundation.org, Alexey Kardashevskiy <aik@ozlabs.ru>, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Thu 06-09-18 14:31:11, Michal Hocko wrote:
> On Thu 06-09-18 11:13:39, Aneesh Kumar K.V wrote:
> > We want to use this to support customized huge page migration.
> 
> Please be much more specific. Ideally including the user. Btw. why do
> you want to skip the hugetlb pools? In other words alloc_huge_page_node*
> which are intended to an external use?

Ups, I have now found http://lkml.kernel.org/r/20180906054342.25094-2-aneesh.kumar@linux.ibm.com
which ended up in a different email folder so I have missed it. It would
be much better to merge those two to make the user immediately obvious.
There is a good reason to keep newly added functions closer to their
users.
-- 
Michal Hocko
SUSE Labs
