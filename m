Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 42BEB6B004F
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 08:06:57 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9KC6sxv010822
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 20 Oct 2009 21:06:54 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 55BEC45DE7D
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 21:06:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2689A45DE60
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 21:06:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EE794E18002
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 21:06:53 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FE18E18004
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 21:06:53 +0900 (JST)
Message-ID: <0f7b4023bee9b7ccc47998cd517d193c.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <COL115-W535064AC2F576372C1BB1B9FC00@phx.gbl>
References: <COL115-W535064AC2F576372C1BB1B9FC00@phx.gbl>
Date: Tue, 20 Oct 2009 21:06:53 +0900 (JST)
Subject: Re: [PATCH] try_to_unuse : remove redundant swap_count()
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bo Liu <bo-liu@hotmail.com>
Cc: akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Bo Liu  wrote:
>
>
> While comparing with swcount,it's no need to
> call swap_count(). Just as int set_start_mm =
> (*swap_map>= swcount) is ok.
>
Hmm ?
*swap_map = (SWAP_HAS_CACHE) | count. What this change means ?

Anyway, swap_count() macro is removed by Hugh's patch (queued in -mm)

Regards,
-Kame

> Signed-off-by: Bo Liu <bo-liu@hotmail.com>
> ---
>
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 63ce10f..2456fc6 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1152,7 +1152,7 @@ static int try_to_unuse(unsigned int type)
>       retval = unuse_mm(mm, entry, page);
>      if (set_start_mm &&
> -        swap_count(*swap_map) < swcount) {
> +         ((*swap_map) < swcount)) {
>       mmput(new_start_mm);
>       atomic_inc(&mm->mm_users);
>       new_start_mm = mm;
>
> --
> 1.6.0.6
> _________________________________________________________________
> Windows Live Hotmail: Your friends can get your Facebook updates, right
from
>  Hotmailョ.
> http://www.microsoft.com/middleeast/windows/windowslive/see-it-in-action/social-network-basics.aspx?ocid=PID23461::T:WLMTAGL:ON:WL:en-xm:SI_SB_4:092009
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
