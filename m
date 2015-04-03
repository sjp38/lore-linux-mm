Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF1F6B0032
	for <linux-mm@kvack.org>; Fri,  3 Apr 2015 04:38:09 -0400 (EDT)
Received: by widdi4 with SMTP id di4so101924266wid.0
        for <linux-mm@kvack.org>; Fri, 03 Apr 2015 01:38:08 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fw4si2255700wic.69.2015.04.03.01.38.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 03 Apr 2015 01:38:07 -0700 (PDT)
Message-ID: <551E516D.4050803@suse.cz>
Date: Fri, 03 Apr 2015 10:38:05 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch] mm, memcg: sync allocation and memcg charge gfp flags
 for thp fix fix
References: <1426514892-7063-1-git-send-email-mhocko@suse.cz> <55098D0A.8090605@suse.cz> <20150318150257.GL17241@dhcp22.suse.cz> <55099C72.1080102@suse.cz> <20150318155905.GO17241@dhcp22.suse.cz> <5509A31C.3070108@suse.cz> <20150318161407.GP17241@dhcp22.suse.cz> <alpine.DEB.2.10.1504021836180.20229@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1504021836180.20229@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/03/2015 03:41 AM, David Rientjes wrote:
> "mm, memcg: sync allocation and memcg charge gfp flags for THP" in -mm
> introduces a formal to pass the gfp mask for khugepaged's hugepage
> allocation.  This is just too ugly to live.
>
> alloc_hugepage_gfpmask() cannot differ between NUMA and UMA configs by
> anything in GFP_RECLAIM_MASK, which is the only thing that matters for
> memcg reclaim, so just determine the gfp flags once in
> collapse_huge_page() and avoid the complexity.
>
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
