Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0276C6B02AC
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 12:18:12 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id r16-v6so5912578pgv.17
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 09:18:11 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u13-v6si4433077pfc.79.2018.10.25.09.18.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Oct 2018 09:18:10 -0700 (PDT)
Date: Thu, 25 Oct 2018 09:18:05 -0700
In-Reply-To: <20181025161410.GT18839@dhcp22.suse.cz>
References: <20180925120326.24392-1-mhocko@kernel.org> <20180925120326.24392-3-mhocko@kernel.org> <20180926133039.y7o5x4nafovxzh2s@kshutemo-mobl1> <20180926141708.GX6278@dhcp22.suse.cz> <20180926142227.GZ6278@dhcp22.suse.cz> <20181018191147.33e8d5e1ebd785c06aab7b30@linux-foundation.org> <20181019080657.GJ18839@dhcp22.suse.cz> <583b20e5-4925-e175-1533-5c2d2bab9192@suse.cz> <20181024161754.0d174e7c22113f4f8aad1940@linux-foundation.org> <983e0c59-99ef-796c-bfc4-00e67782d1f1@suse.cz> <20181025161410.GT18839@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH 2/2] mm, thp: consolidate THP gfp handling into alloc_hugepage_direct_gfpmask
From: Andrew Morton <akpm@linux-foundation.org>
Message-ID: <E0A009A6-FF31-459E-B223-6743C395F659@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>



On October 25, 2018 9:14:10 AM PDT, Michal Hocko <mhocko@kernel=2Eorg> wro=
te:

>Andrew=2E Do you want me to repost the patch or you plan to update the
>changelog yourself?

Please send a replacement changelog and I'll paste it in? 
