Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EB4466B006A
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 19:49:06 -0500 (EST)
Received: by yxe10 with SMTP id 10so4474761yxe.12
        for <linux-mm@kvack.org>; Sun, 01 Nov 2009 16:49:05 -0800 (PST)
Date: Mon, 2 Nov 2009 09:46:30 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCHv2 4/5] vmscan: Kill sc.swap_cluster_max
Message-Id: <20091102094630.9b006e3f.minchan.kim@barrios-desktop>
In-Reply-To: <20091102001110.F40A.A69D9226@jp.fujitsu.com>
References: <20091101234614.F401.A69D9226@jp.fujitsu.com>
	<20091102001110.F40A.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Nov 2009 00:12:02 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Now, all caller is settng to swap_cluster_max = SWAP_CLUSTER_MAX.
> Then, we can remove it perfectly.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
