Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 379BC6B004D
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 12:56:57 -0500 (EST)
Message-ID: <4AEDCBE3.6030407@redhat.com>
Date: Sun, 01 Nov 2009 12:56:51 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 4/5] vmscan: Kill sc.swap_cluster_max
References: <20091101234614.F401.A69D9226@jp.fujitsu.com> <20091102001110.F40A.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091102001110.F40A.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 11/01/2009 10:12 AM, KOSAKI Motohiro wrote:
> Now, all caller is settng to swap_cluster_max = SWAP_CLUSTER_MAX.
> Then, we can remove it perfectly.
>
> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
