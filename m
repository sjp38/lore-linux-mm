Date: Thu, 17 Jan 2008 23:21:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH] a bit improvement of ZONE_DMA page reclaim
Message-Id: <20080117232147.85ae8cab.akpm@linux-foundation.org>
In-Reply-To: <20080118151822.8FAE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080118151822.8FAE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Rik van Riel <riel@redhat.com>, Daniel Spang <daniel.spang@gmail.com>
List-ID: <linux-mm.kvack.org>

On Fri, 18 Jan 2008 15:34:33 +0900 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Hi
> 
> on X86, ZONE_DMA is very very small.
> It is often no used at all. 

In that case page-reclaim is supposed to set all_unreclaimable and
basically ignores the zone altogether until it looks like something might
have changed.

Is that code not working?  (quite possible).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
