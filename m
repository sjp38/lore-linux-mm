Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5829C6B030E
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 06:05:44 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7KA5fBX032636
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 20 Aug 2010 19:05:41 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 54F9745DE58
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 19:05:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 30F8E45DE4E
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 19:05:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D5281DB8016
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 19:05:41 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 914CC1DB8018
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 19:05:40 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] writeback: nr_dirtied and nr_entered_writeback in /proc/vmstat
In-Reply-To: <1282296689-25618-4-git-send-email-mrubin@google.com>
References: <1282296689-25618-1-git-send-email-mrubin@google.com> <1282296689-25618-4-git-send-email-mrubin@google.com>
Message-Id: <20100820190329.6000.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 20 Aug 2010 19:05:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, jack@suse.cz, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, npiggin@kernel.dk, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index f389168..073a496 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -732,6 +732,9 @@ static const char * const vmstat_text[] = {
>  	"nr_isolated_anon",
>  	"nr_isolated_file",
>  	"nr_shmem",
> +	"nr_dirtied",
> +	"nr_entered_writeback",
> +
>  #ifdef CONFIG_NUMA
>  	"numa_hit",
>  	"numa_miss",

'nr_entered_writeback' seems ok. but nr_dirtied seems a bit easy confusable
with 'nr_dirty'. Can you please choice more clear meaningful name?

Otherwise looks good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
