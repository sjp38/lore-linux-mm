Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3DABD9003C7
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 22:22:31 -0400 (EDT)
Received: by qkeo142 with SMTP id o142so43180668qke.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 19:22:31 -0700 (PDT)
Received: from mail-qg0-x234.google.com (mail-qg0-x234.google.com. [2607:f8b0:400d:c04::234])
        by mx.google.com with ESMTPS id m77si4717778qgm.53.2015.07.01.19.22.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 19:22:29 -0700 (PDT)
Received: by qgat90 with SMTP id t90so8459525qga.0
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 19:22:29 -0700 (PDT)
Date: Wed, 1 Jul 2015 22:22:26 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 36/51] writeback: implement bdi_for_each_wb()
Message-ID: <20150702022226.GH26440@mtj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-37-git-send-email-tj@kernel.org>
 <20150701072757.GW7252@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150701072757.GW7252@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Wed, Jul 01, 2015 at 09:27:57AM +0200, Jan Kara wrote:
> > +#define bdi_for_each_wb(wb_cur, bdi, iter, start_blkcg_id)		\
> > +	for ((iter)->next_id = (start_blkcg_id);			\
> > +	     ({	(wb_cur) = !(iter)->next_id++ ? &(bdi)->wb : NULL; }); )
> > +
> 
> This looks quite confusing. Won't it be easier to understand as:
> 
> struct wb_iter {
> } __attribute__ ((unused));
> 
> #define bdi_for_each_wb(wb_cur, bdi, iter, start_blkcg_id) \
>   if (((wb_cur) = (!start_blkcg_id ? &(bdi)->wb : NULL)))

But then break or continue wouldn't work as expected.  It can get
really confusing when it's wrapped by an outer loop.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
