Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2C0036B004D
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 16:34:05 -0400 (EDT)
Message-ID: <4ACF9E2F.3090307@redhat.com>
Date: Fri, 09 Oct 2009 16:33:51 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] vmscan: separate sc.swap_cluster_max and sc.nr_max_reclaim
References: <20091009174756.12B5.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091009174756.12B5.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Rafael, Can you please review this patch series?
> 
> I found shrink_all_memory() is not fast at all on my numa system.
> I think this patch series fixes it.
> 
> 
> ==============================================================
> Currently, sc.scap_cluster_max has double meanings.
> 
>  1) reclaim batch size as isolate_lru_pages()'s argument
>  2) reclaim baling out thresolds
> 
> The two meanings pretty unrelated. Thus, Let's separate it.
> this patch doesn't change any behavior.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
