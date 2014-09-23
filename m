Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9E6CB6B0037
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 00:45:16 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id r10so5788321pdi.40
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 21:45:16 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id nk11si12394195pdb.213.2014.09.22.21.45.14
        for <linux-mm@kvack.org>;
        Mon, 22 Sep 2014 21:45:15 -0700 (PDT)
Date: Tue, 23 Sep 2014 13:45:51 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 2/5] mm: add full variable in swap_info_struct
Message-ID: <20140923044551.GB8325@bbox>
References: <1411344191-2842-1-git-send-email-minchan@kernel.org>
 <1411344191-2842-3-git-send-email-minchan@kernel.org>
 <20140922134522.00725f561fdae318446a41cb@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20140922134522.00725f561fdae318446a41cb@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, juno.choi@lge.com

On Mon, Sep 22, 2014 at 01:45:22PM -0700, Andrew Morton wrote:
> On Mon, 22 Sep 2014 09:03:08 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > Now, swap leans on !p->highest_bit to indicate a swap is full.
> > It works well for normal swap because every slot on swap device
> > is used up when the swap is full but in case of zram, swap sees
> > still many empty slot although backed device(ie, zram) is full
> > since zram's limit is over so that it could make trouble when
> > swap use highest_bit to select new slot via free_cluster.
> > 
> > This patch introduces full varaiable in swap_info_struct
> > to solve the problem.
> > 
> > ...
> >
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -224,6 +224,7 @@ struct swap_info_struct {
> >  	struct swap_cluster_info free_cluster_tail; /* free cluster list tail */
> >  	unsigned int lowest_bit;	/* index of first free in swap_map */
> >  	unsigned int highest_bit;	/* index of last free in swap_map */
> > +	bool	full;			/* whether swap is full or not */
> 
> This is protected by swap_info_struct.lock, I worked out.
> 
> There's a large comment at swap_info_struct.lock which could be updated.

Sure.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
