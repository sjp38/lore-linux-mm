Date: Tue, 26 Apr 2005 01:36:32 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: VM 5/8 async-writepage
Message-Id: <20050426013632.55e958c8.akpm@osdl.org>
In-Reply-To: <17005.64094.860824.34597@gargle.gargle.HOWL>
References: <16994.40662.865338.484778@gargle.gargle.HOWL>
	<20050425205706.55fe9833.akpm@osdl.org>
	<17005.64094.860824.34597@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov <nikita@clusterfs.com> wrote:
>
>  > 
>   > I don't understand this at all.  ->writepage() is _already_ asynchronous. 
>   > It will only block under rare circumstances such as needing to perform a
>   > metadata read or encountering disk queue congestion.
> 
>  This patch tries to decrease latency of direct reclaim by avoiding
> 
>    - occasional stalls you mentioned, and
> 
>    - CPU cost of ->writepage().

Seems a bit pointless then?

Have you quantified this?

>  Plus, deferred pageouts will be easier to cluster.

hm.  Why?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
