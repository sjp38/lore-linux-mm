Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id A49E46B0005
	for <linux-mm@kvack.org>; Wed,  4 May 2016 17:23:20 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 68so52989575lfq.2
        for <linux-mm@kvack.org>; Wed, 04 May 2016 14:23:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k5si7314101wjh.103.2016.05.04.14.23.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 May 2016 14:23:19 -0700 (PDT)
Subject: Re: kcompactd hang during memory offlining
References: <20160503170247.GA4239@arbab-laptop.austin.ibm.com>
 <5729234A.1080502@suse.cz>
 <20160504180901.GB4239@arbab-laptop.austin.ibm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <98fb9fb2-bf17-a15d-2afd-5be4afacc237@suse.cz>
Date: Wed, 4 May 2016 23:23:15 +0200
MIME-Version: 1.0
In-Reply-To: <20160504180901.GB4239@arbab-laptop.austin.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 4.5.2016 20:09, Reza Arbab wrote:
> On Wed, May 04, 2016 at 12:16:42AM +0200, Vlastimil Babka wrote:
>> Damn, can you test this patch?
> 
> That fixed the regression for me. Thanks!
> 
> Tested-by: Reza Arbab <arbab@linux.vnet.ibm.com>

Thanks for testing, and Andrew for picking the patch already!

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
