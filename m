Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 792816B0024
	for <linux-mm@kvack.org>; Mon,  9 May 2011 03:51:14 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id CA6743EE0C5
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:51:10 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B0AFD45DE4F
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:51:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F96945DE59
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:51:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 836C21DB802F
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:51:10 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 41E731DB8043
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:51:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 7/8] proc: make struct proc_maps_private truly private
In-Reply-To: <1303947349-3620-8-git-send-email-wilsons@start.ca>
References: <1303947349-3620-1-git-send-email-wilsons@start.ca> <1303947349-3620-8-git-send-email-wilsons@start.ca>
Message-Id: <20110509165255.1667.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  9 May 2011 16:51:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Wilson <wilsons@start.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> Now that mm/mempolicy.c is no longer implementing /proc/pid/numa_maps
> there is no need to export struct proc_maps_private to the world.  Move
> it to fs/proc/internal.h instead.
> 
> Signed-off-by: Stephen Wilson <wilsons@start.ca>
> ---
>  fs/proc/internal.h      |    8 ++++++++
>  include/linux/proc_fs.h |    8 --------
>  2 files changed, 8 insertions(+), 8 deletions(-)

Looks good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
