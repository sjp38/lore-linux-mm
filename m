Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 930B36B78BE
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 08:31:16 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c25-v6so3511365edb.12
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 05:31:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z37-v6si5465087edc.189.2018.09.06.05.31.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 05:31:15 -0700 (PDT)
Date: Thu, 6 Sep 2018 14:31:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH V2 1/4] mm: Export alloc_migrate_huge_page
Message-ID: <20180906123111.GC26069@dhcp22.suse.cz>
References: <20180906054342.25094-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180906054342.25094-1-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: akpm@linux-foundation.org, Alexey Kardashevskiy <aik@ozlabs.ru>, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Thu 06-09-18 11:13:39, Aneesh Kumar K.V wrote:
> We want to use this to support customized huge page migration.

Please be much more specific. Ideally including the user. Btw. why do
you want to skip the hugetlb pools? In other words alloc_huge_page_node*
which are intended to an external use?

-- 
Michal Hocko
SUSE Labs
