Date: Sun, 29 Jun 2008 11:17:09 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH -mm] kill unused lru functions
Message-ID: <20080629111709.2dbdfe6e@bree.surriel.com>
In-Reply-To: <20080629190905.37CF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080629190905.37CF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, 29 Jun 2008 19:12:16 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> several LRU manupuration function is not used now.
> So, it can be removed.
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
