Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B69CA828E1
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 14:30:44 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 4so33147352wmz.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 11:30:44 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id i83si15949667wmf.117.2016.06.13.11.30.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 11:30:43 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id k184so16849483wme.2
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 11:30:43 -0700 (PDT)
Date: Mon, 13 Jun 2016 21:30:38 +0300
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: Re: [RFC PATCH 0/3] mm, thp: convert from optimistic to conservative
Message-ID: <20160613183038.GA3815@debian>
References: <1465672561-29608-1-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465672561-29608-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, minchan@kernel.org

On Sat, Jun 11, 2016 at 10:15:58PM +0300, Ebru Akagunduz wrote:
> This patch series converts thp design from optimistic to conservative, 
> creates a sysfs integer knob for conservative threshold and documents it.
> 
This patchset follows Michan Kim's suggestion.
Related discussion is here:
http://marc.info/?l=linux-mm&m=146373278424897&w=2

CC'ed Michan Kim.

> Ebru Akagunduz (3):
>   mm, thp: revert allocstall comparing
>   mm, thp: convert from optimistic to conservative
>   doc: add information about min_ptes_young
> 
>  Documentation/vm/transhuge.txt     |  7 ++++
>  include/trace/events/huge_memory.h | 10 ++---
>  mm/khugepaged.c                    | 81 ++++++++++++++++++++++----------------
>  3 files changed, 59 insertions(+), 39 deletions(-)
> 
> -- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
