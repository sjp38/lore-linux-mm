Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8FB556B0261
	for <linux-mm@kvack.org>; Wed, 24 Aug 2016 16:47:25 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id i184so51400616ywb.1
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 13:47:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w126si2873763yba.109.2016.08.24.13.47.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Aug 2016 13:47:25 -0700 (PDT)
Message-ID: <1472071627.2751.33.camel@redhat.com>
Subject: Re: [PATCH] mm, swap: Add swap_cluster_list
From: Rik van Riel <riel@redhat.com>
Date: Wed, 24 Aug 2016 16:47:07 -0400
In-Reply-To: <1472067356-16004-1-git-send-email-ying.huang@intel.com>
References: <1472067356-16004-1-git-send-email-ying.huang@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>

On Wed, 2016-08-24 at 12:35 -0700, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> This is a code clean up patch without functionality changes.A A The
> swap_cluster_list data structure and its operations are introduced to
> provide some better encapsulation for the free cluster and discard
> cluster list operations.A A This avoid some code duplication, improved
> the code readability, and reduced the total line number.
> 
> Cc: Tim Chen <tim.c.chen@intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>
> Acked-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> 

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
