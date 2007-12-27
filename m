Date: Thu, 27 Dec 2007 16:05:39 -0500
From: Marcelo Tosatti <marcelo@kvack.org>
Subject: Re: [RFC] add poll_wait_exclusive() API
Message-ID: <20071227210539.GC14823@dmt>
References: <20071224203250.GA23149@dmt> <20071225122326.D25C.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20071225135102.D25F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071225135102.D25F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <marcelo@kvack.org>, Daniel =?utf-8?B?U3DomqNn?= <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 25, 2007 at 01:56:24PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> add item to wait queue exist 2 way, add_wait_queue() and add_wait_queue_exclusive().
> but unfortunately, we only able to use poll_wait in poll method.
> 
> poll_wait_exclusive() works similar as add_wait_queue_exclusive()
> 
> 
> caution:
>   this patch is compile test only.
>   my purpose is discussion only.

Looks good. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
