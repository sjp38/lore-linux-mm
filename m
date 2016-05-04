Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f71.google.com (mail-qg0-f71.google.com [209.85.192.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9F3596B0005
	for <linux-mm@kvack.org>; Wed,  4 May 2016 14:09:12 -0400 (EDT)
Received: by mail-qg0-f71.google.com with SMTP id e35so95163253qge.0
        for <linux-mm@kvack.org>; Wed, 04 May 2016 11:09:12 -0700 (PDT)
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com. [32.97.110.152])
        by mx.google.com with ESMTPS id f135si3358304qke.148.2016.05.04.11.09.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 04 May 2016 11:09:11 -0700 (PDT)
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 4 May 2016 12:09:09 -0600
Date: Wed, 4 May 2016 13:09:01 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: kcompactd hang during memory offlining
Message-ID: <20160504180901.GB4239@arbab-laptop.austin.ibm.com>
References: <20160503170247.GA4239@arbab-laptop.austin.ibm.com>
 <5729234A.1080502@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <5729234A.1080502@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Arnd Bergmann <arnd@arndb.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, May 04, 2016 at 12:16:42AM +0200, Vlastimil Babka wrote:
>Damn, can you test this patch?

That fixed the regression for me. Thanks!

Tested-by: Reza Arbab <arbab@linux.vnet.ibm.com>

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
