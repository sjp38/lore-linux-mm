Message-ID: <4932B02B.3020502@redhat.com>
Date: Sun, 30 Nov 2008 10:24:27 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/09] memcg: make inactive_anon_is_low()
References: <20081130193502.8145.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081130195508.814B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20081130195508.814B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> make inactive_anon_is_low for memcgroup.
> it improve active_anon vs inactive_anon ratio balancing.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Looking forward to the cleanups, but since the code is correct
here's an early:

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
