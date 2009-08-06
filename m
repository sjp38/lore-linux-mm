Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 274F76B005C
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 06:52:28 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n76AqWIQ018565
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 6 Aug 2009 19:52:32 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B2AC45DE6E
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 19:52:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 561CC45DE4D
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 19:52:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C0A61DB803A
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 19:52:31 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id ECF801DB8037
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 19:52:27 +0900 (JST)
Date: Thu, 6 Aug 2009 19:50:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mv clear node_load[] to __build_all_zonelists()
Message-Id: <20090806195037.06e768f5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <COL115-W869FC30815A7D5B7A63339F0A0@phx.gbl>
References: <COL115-W869FC30815A7D5B7A63339F0A0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Bo Liu <bo-liu@hotmail.com>
Cc: akpm@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, mel@csn.ul.ie, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 6 Aug 2009 18:44:40 +0800
Bo Liu <bo-liu@hotmail.com> wrote:

> 
>  If node_load[] is cleared everytime build_zonelists() is called,node_load[]
>  will have no help to find the next node that should appear in the given node's
>  fallback list.
>  Signed-off-by: Bob Liu 

nice catch. (my old bug...sorry

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

BTW, do you have special reasons to hide your mail address in commit log ?

I added proper CC: list.
Hmm, I think it's necessary to do total review/rewrite this function again..


> ---
>  mm/page_alloc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d052abb..72f7345 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2544,7 +2544,6 @@ static void build_zonelists(pg_data_t *pgdat)
>  	prev_node = local_node;
>  	nodes_clear(used_mask);
>  
> -	memset(node_load, 0, sizeof(node_load));
>  	memset(node_order, 0, sizeof(node_order));
>  	j = 0;
>  
> @@ -2653,6 +2652,7 @@ static int __build_all_zonelists(void *dummy)
>  {
>  	int nid;
>  
> +	memset(node_load, 0, sizeof(node_load));
>  	for_each_online_node(nid) {
>  		pg_data_t *pgdat = NODE_DATA(nid);
> 
> 
> 
> 
> _________________________________________________________________
> Drag na?? dropa??Get easy photo sharing with Windows Livea?c Photos.
> 
> http://www.microsoft.com/windows/windowslive/products/photos.aspx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
