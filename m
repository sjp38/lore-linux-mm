Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9A0966B0292
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 05:16:34 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id o202so167614954itc.14
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 02:16:34 -0700 (PDT)
Received: from mail-io0-x22b.google.com (mail-io0-x22b.google.com. [2607:f8b0:4001:c06::22b])
        by mx.google.com with ESMTPS id k131si16073931iok.235.2017.07.17.02.16.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 02:16:34 -0700 (PDT)
Received: by mail-io0-x22b.google.com with SMTP id h64so39850956iod.0
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 02:16:33 -0700 (PDT)
Message-ID: <1500282938.8256.9.camel@gmail.com>
Subject: Re: [PATCH 5/6] mm/memcontrol: support MEMORY_DEVICE_PRIVATE and
 MEMORY_DEVICE_PUBLIC v3
From: Balbir Singh <bsingharora@gmail.com>
Date: Mon, 17 Jul 2017 19:15:38 +1000
In-Reply-To: <20170713211532.970-6-jglisse@redhat.com>
References: <20170713211532.970-1-jglisse@redhat.com>
	 <20170713211532.970-6-jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org

On Thu, 2017-07-13 at 17:15 -0400, JA(C)rA'me Glisse wrote:
> HMM pages (private or public device pages) are ZONE_DEVICE page and
> thus need special handling when it comes to lru or refcount. This
> patch make sure that memcontrol properly handle those when it face
> them. Those pages are use like regular pages in a process address
> space either as anonymous page or as file back page. So from memcg
> point of view we want to handle them like regular page for now at
> least.
> 
> Changed since v2:
>   - s/host/public
> Changed since v1:
>   - s/public/host
>   - add comments explaining how device memory behave and why
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: cgroups@vger.kernel.org
> ---

Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
