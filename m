Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B42706B0261
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 06:30:14 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t10so16508747pgo.20
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 03:30:14 -0700 (PDT)
Received: from BJEXCAS003.didichuxing.com ([36.110.17.22])
        by mx.google.com with ESMTPS id 1si1158096plk.740.2017.10.31.03.30.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 03:30:13 -0700 (PDT)
Date: Tue, 31 Oct 2017 18:30:06 +0800
From: weiping zhang <zhangweiping@didichuxing.com>
Subject: Re: [PATCH 1/4] bdi: add check for bdi_debug_root
Message-ID: <20171031103006.GA1616@source.didichuxing.com>
References: <cover.1509038624.git.zhangweiping@didichuxing.com>
 <883f8bb529fbde0d4adc2b78ba3bbda81e1ce6a0.1509038624.git.zhangweiping@didichuxing.com>
 <20171030130028.GG23278@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20171030130028.GG23278@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-block@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 30, 2017 at 02:00:28PM +0100, Jan Kara wrote:
> On Fri 27-10-17 01:35:36, weiping zhang wrote:
> > this patch add a check for bdi_debug_root and do error handle for it.
> > we should make sure it was created success, otherwise when add new
> > block device's bdi folder(eg, 8:0) will be create a debugfs root directory.
> > 
> > Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>
> > ---
> >  mm/backing-dev.c | 17 ++++++++++++++---
> >  1 file changed, 14 insertions(+), 3 deletions(-)
> 
> These functions get called only on system boot - ENOMEM in those cases is
> generally considered fatal and oopsing is acceptable result. So I don't
> think this patch is needed.
> 
OK, I drop this patch.

Thanks a ton.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
