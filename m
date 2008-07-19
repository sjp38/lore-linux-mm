Date: Sat, 19 Jul 2008 10:41:10 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [-mm][splitlru][PATCH 2/3] split LRU: munlock rework
Message-ID: <20080719104110.5bd6a199@bree.surriel.com>
In-Reply-To: <20080719084303.857060828@jp.fujitsu.com>
References: <20080719084213.588795788@jp.fujitsu.com>
	<20080719084303.857060828@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kosaki.motohiro@jp.fujitsu.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Li Zefan <lizf@cn.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Sat, 19 Jul 2008 17:42:15 +0900
kosaki.motohiro@jp.fujitsu.com wrote:

> current munlock processing use to pagewalk.
> its cause two problems.
>   - build error on nommu machine
>   - runtime error on HIGHPTE machine.
> 
> This patch fixes it.
> 
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
