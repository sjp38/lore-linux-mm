Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5A20E6B0032
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 21:26:08 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id y13so2327572pdi.3
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 18:26:08 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id bu11si8064832pdb.95.2014.12.19.18.26.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 19 Dec 2014 18:26:07 -0800 (PST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so2316494pab.30
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 18:26:06 -0800 (PST)
Date: Sat, 20 Dec 2014 11:25:57 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm/zsmalloc: add statistics support
Message-ID: <20141220022557.GA19822@blaptop>
References: <1418993719-14291-1-git-send-email-opensource.ganesh@gmail.com>
 <20141219143244.1e5fabad8b6733204486f5bc@linux-foundation.org>
 <20141219233937.GA11975@blaptop>
 <20141219154548.3aa4cc02b3322f926aa4c1d6@linux-foundation.org>
 <20141219235852.GB11975@blaptop>
 <20141219160648.5cea8a6b0c764caa6100a585@linux-foundation.org>
 <20141220001043.GC11975@blaptop>
 <20141219161756.bcf7421acb4bc7a286c1afa3@linux-foundation.org>
 <20141220002303.GD11975@blaptop>
 <CADAEsF-=RwwR2D_LzhVYKhfmfPCsQE73bJYyH=tjn4BtHVrdew@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADAEsF-=RwwR2D_LzhVYKhfmfPCsQE73bJYyH=tjn4BtHVrdew@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Hey Ganesh,

On Sat, Dec 20, 2014 at 09:43:34AM +0800, Ganesh Mahendran wrote:
> 2014-12-20 8:23 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> > On Fri, Dec 19, 2014 at 04:17:56PM -0800, Andrew Morton wrote:
> >> On Sat, 20 Dec 2014 09:10:43 +0900 Minchan Kim <minchan@kernel.org> wrote:
> >>
> >> > > It involves rehashing a lengthy argument with Greg.
> >> >
> >> > Okay. Then, Ganesh,
> >> > please add warn message about duplicaed name possibility althoug
> >> > it's unlikely as it is.
> >>
> >> Oh, getting EEXIST is easy with this patch.  Just create and destroy a
> >> pool 2^32 times and the counter wraps ;) It's hardly a serious issue
> >> for a debugging patch.
> >
> > I meant that I wanted to change from index to name passed from caller like this
> >
> > zram:
> >         zs_create_pool(GFP_NOIO | __GFP_HIGHMEM, zram->disk->first_minor);
> >
> > So, duplication should be rare. :)
> 
> We still can not know whether the name is duplicated if we do not
> change the debugfs API.
> The API does not return the errno to us.
> 
> How about just zsmalloc decides the name of the pool-id, like pool-x.
> When the pool-id reaches
> 0xffff.ffff, we print warn message about duplicated name, and stop
> creating the debugfs entry
> for the user.

The idea is from the developer point of view to implement thing easy
but my point is we should take care of user(ie, admin) rather than
developer(ie, we).

For user, /sys/kernel/debug/zsmalloc/zram0 would be more
straightforward and even it doesn't need zram to export
/sys/block/zram0/pool-id.

Thanks.

> 
> Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
