Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0C0C28E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 04:51:16 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p51-v6so8086877eda.18
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 01:51:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o14si1209851edv.250.2018.09.11.01.51.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 01:51:14 -0700 (PDT)
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
References: <20180907130550.11885-1-mhocko@kernel.org>
 <alpine.DEB.2.21.1809101253080.177111@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <21336327-2465-ba55-e721-4e48f782dff1@suse.cz>
Date: Tue, 11 Sep 2018 10:51:12 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1809101253080.177111@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Stefan Priebe <s.priebe@profihost.ag>

On 09/10/2018 10:08 PM, David Rientjes wrote:
> When Andrea brought this up, I suggested that the full solution would be a 
> MPOL_F_HUGEPAGE flag that could define thp allocation policy -- the added 

Can you elaborate on the semantics of this? You mean that a given vma
could now have two mempolicies, where one would be for hugepages only?
That's likely much more easy to suggest than to implement, with all uapi
consequences...

> benefit is that we could replace the thp "defrag" mode default by setting 
> this as part of default_policy.  Right now, MADV_HUGEPAGE users are 
> concerned about (1) getting thp when system-wide it is not default and (2) 
> additional fault latency when direct compaction is not default.  They are 
> not anticipating the degradation of remote access latency, so overloading 
> the meaning of the mode is probably not a good idea.
> 
