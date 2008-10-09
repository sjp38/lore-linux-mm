Message-ID: <48EDE9BD.9070602@redhat.com>
Date: Thu, 09 Oct 2008 07:23:41 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [mmotm 02/Oct PATCH 1/3] adjust Quicklists field of /proc/meminfo
References: <20081009153432.DEC7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20081009153432.DEC7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> vmscan-split-lru-lists-into-anon-file-sets.patch changed /proc/meminfo output length,
> but only Quicklists: field doesn't.
> (because quicklists field added after than split-lru)

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
