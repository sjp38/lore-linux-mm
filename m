Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 253206B005C
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 10:47:08 -0400 (EDT)
Message-ID: <4A5606DB.7060503@redhat.com>
Date: Thu, 09 Jul 2009 11:03:55 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] add shmem vmstat
References: <20090709165820.23B7.A69D9226@jp.fujitsu.com> <20090709171452.23C9.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090709171452.23C9.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> ChangeLog
>   Since v1
>    - Fixed misaccounting bug on page migration
> 
> ========================
> Subject: [PATCH] add shmem vmstat
> 
> Recently, We faced several OOM problem by plenty GEM cache. and generally,
> plenty Shmem/Tmpfs potentially makes memory shortage problem.
> 
> We often use following calculation to know shmem pages,
>   shmem = NR_ACTIVE_ANON + NR_INACTIVE_ANON - NR_ANON_PAGES
> but it is wrong expression. it doesn't consider isolated page and
> mlocked page.
> 
> Then, This patch make explicit Shmem/Tmpfs vm-stat accounting.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
