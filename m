Message-ID: <486DFCF7.3010104@openvz.org>
Date: Fri, 04 Jul 2008 14:35:35 +0400
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memcg: check limit change
References: <20080704181204.44070413.kamezawa.hiroyu@jp.fujitsu.com> <20080704181606.4e9187e7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080704181606.4e9187e7.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Shrinking memory usage at limit change.
> 
> Changelog: v1 -> v2
>   - adjusted to be based on write_string() patch set
>   fixed pointed out styles (below)
>   - removed backword goto.
>   - removed unneccesary cond_resched().
> 
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

Acked-by: Pavel Emelyanov <xemul@openvz.org>

> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
