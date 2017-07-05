Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id AEA296B0292
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 23:18:20 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o3so115775279qto.15
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 20:18:20 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id o14si5079790qti.116.2017.07.04.20.18.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jul 2017 20:18:19 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id 91so29781897qkq.1
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 20:18:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170704125113.GC14727@dhcp22.suse.cz>
References: <20170703211415.11283-1-jglisse@redhat.com> <20170703211415.11283-5-jglisse@redhat.com>
 <20170704125113.GC14727@dhcp22.suse.cz>
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 5 Jul 2017 13:18:18 +1000
Message-ID: <CAKTCnz=zTjYeqeTYZbnOMsT1Ccus4yW=jAws_OgXp3q4xmuSPA@mail.gmail.com>
Subject: Re: [PATCH 4/5] mm/memcontrol: allow to uncharge page without using
 page->lru field
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>

On Tue, Jul 4, 2017 at 10:51 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Mon 03-07-17 17:14:14, J=C3=A9r=C3=B4me Glisse wrote:
>> HMM pages (private or public device pages) are ZONE_DEVICE page and
>> thus you can not use page->lru fields of those pages. This patch
>> re-arrange the uncharge to allow single page to be uncharge without
>> modifying the lru field of the struct page.
>>
>> There is no change to memcontrol logic, it is the same as it was
>> before this patch.
>
> What is the memcg semantic of the memory? Why is it even charged? AFAIR
> this is not a reclaimable memory. If yes how are we going to deal with
> memory limits? What should happen if go OOM? Does killing an process
> actually help to release that memory? Isn't it pinned by a device?
>
> For the patch itself. It is quite ugly but I haven't spotted anything
> obviously wrong with it. It is the memcg semantic with this class of
> memory which makes me worried.
>

This is the HMM CDM case. Memory is normally malloc'd and then
migrated to ZONE_DEVICE or vice-versa. One of the things we did
discuss was seeing ZONE_DEVICE memory in user page tables.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
