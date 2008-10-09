Message-ID: <48EDE9DD.208@redhat.com>
Date: Thu, 09 Oct 2008 07:24:13 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [mmotm 02/Oct PATCH 2/3] adjust hugepage related field of /proc/meminfo
References: <20081009153432.DEC7.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081009153854.DECD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20081009153854.DECD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> adjust hugepage related field in /proc/meminfo.
> (because vmscan-split-lru-lists-into-anon-file-sets.patch changed
> length of other field)

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
