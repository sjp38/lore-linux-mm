Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 41DFA6B0397
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 09:06:51 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id v3so4836602qtd.6
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 06:06:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n51si4768345qtb.26.2017.04.07.06.06.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Apr 2017 06:06:50 -0700 (PDT)
Message-ID: <1491570407.8850.164.camel@redhat.com>
Subject: Re: [PATCH -mm -v3] mm, swap: Use kvzalloc to allocate some swap
 data structure
From: Rik van Riel <riel@redhat.com>
Date: Fri, 07 Apr 2017 09:06:47 -0400
In-Reply-To: <20170407064911.25447-1-ying.huang@intel.com>
References: <20170407064911.25447-1-ying.huang@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>

On Fri, 2017-04-07 at 14:49 +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> Now vzalloc() is used in swap code to allocate various data
> structures, such as swap cache, swap slots cache, cluster info, etc.
> Because the size may be too large on some system, so that normal
> kzalloc() may fail.A A But using kzalloc() has some advantages,

> Signed-off-by: Huang Ying <ying.huang@intel.com>
> Acked-by: Tim Chen <tim.c.chen@intel.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>
> 
Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
