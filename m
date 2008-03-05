Date: Tue, 4 Mar 2008 23:21:56 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 11/20] No Reclaim LRU Infrastructure
Message-ID: <20080304232156.10fe473a@bree.surriel.com>
In-Reply-To: <47CDEA95.9050507@gmail.com>
References: <20080304225157.573336066@redhat.com>
	<20080304225227.455963956@redhat.com>
	<47CDEA95.9050507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: minchan Kim <minchan.kim@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 05 Mar 2008 09:34:29 +0900
minchan Kim <minchan.kim@gmail.com> wrote:

> We don't use is_lru_page any more.
> It cause warning at compile time.
> 
> We can remove is_lru_page local variable.

I have applied this fix too.  Thank you.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
