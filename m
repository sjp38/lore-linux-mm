Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1D163280260
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 13:06:55 -0400 (EDT)
Received: by ykdy1 with SMTP id y1so100412985ykd.2
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 10:06:54 -0700 (PDT)
Received: from mail-yk0-x229.google.com (mail-yk0-x229.google.com. [2607:f8b0:4002:c07::229])
        by mx.google.com with ESMTPS id l10si6651216ykd.24.2015.07.03.10.06.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jul 2015 10:06:54 -0700 (PDT)
Received: by ykfy125 with SMTP id y125so100450131ykf.1
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 10:06:54 -0700 (PDT)
Date: Fri, 3 Jul 2015 13:06:51 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 36/51] writeback: implement bdi_for_each_wb()
Message-ID: <20150703170651.GE5273@mtj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-37-git-send-email-tj@kernel.org>
 <20150701072757.GW7252@quack.suse.cz>
 <20150702022226.GH26440@mtj.duckdns.org>
 <20150703122627.GK23329@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150703122627.GK23329@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Fri, Jul 03, 2015 at 02:26:27PM +0200, Jan Kara wrote:
> That's a good point. Thanks for explanation. Maybe add a comment like:
> /*
>  * We use use this seemingly complicated 'for' loop so that 'break' and
>  * 'continue' continue to work as expected.
>  */

This kinda feel superflous for me.  This is something true for all
iteration wrappers which falls within the area of well-established
convention, I think.  If it's doing something weird like combining
if-else clause to do post-conditional processing, sure, but this is
really kinda standard.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
