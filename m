Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB3726B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 03:52:22 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id k100so18243810wrc.9
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 00:52:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g23si326686edg.87.2017.11.27.00.52.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 00:52:21 -0800 (PST)
Date: Mon, 27 Nov 2017 09:52:20 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm: print a warning once the vm dirtiness settings is
 illogical
Message-ID: <20171127085220.kf6gyksfy276mkk6@dhcp22.suse.cz>
References: <CALOAHbCov=Dd7bYjL6+abiVu_WgT1ZmFN_TfLTs8A1jfw8=bOQ@mail.gmail.com>
 <201711261703.HDI52138.JSFVOFOtHLMOFQ@I-love.SAKURA.ne.jp>
 <CALOAHbAgh0egRJk7ME_YBzon9ED9jL94vi4aw19bbpZVuUA+aQ@mail.gmail.com>
 <201711261938.BCD34864.QLVFOSJFHOtOFM@I-love.SAKURA.ne.jp>
 <CALOAHbCVoy=5U0_7wg9nZR+sa8buG41BAE4KDnr2Fb4tYqhaXw@mail.gmail.com>
 <20171127082112.b7elnzy24qiqze46@dhcp22.suse.cz>
 <CALOAHbDZ_rxHYyb8K01Ecd7FBRXO4Bp5_BsPYXAvAOYXMw34Rw@mail.gmail.com>
 <CALOAHbCH1JG=BmpgOwq+7W3wXuHqhXkisj+p-rPXeivTdXa7-w@mail.gmail.com>
 <20171127083707.wsyw5mnhi6juiknh@dhcp22.suse.cz>
 <CALOAHbD6txwh3dUdv1bSju2PMHyUE1kW4Qt7gyAxpwToie54Rw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbD6txwh3dUdv1bSju2PMHyUE1kW4Qt7gyAxpwToie54Rw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Linux MM <linux-mm@kvack.org>, fcicq@fcicq.net

On Mon 27-11-17 16:49:34, Yafang Shao wrote:
> 2017-11-27 16:37 GMT+08:00 Michal Hocko <mhocko@suse.com>:
> > On Mon 27-11-17 16:32:42, Yafang Shao wrote:
> >> 2017-11-27 16:29 GMT+08:00 Yafang Shao <laoar.shao@gmail.com>:
[...]
> >> > It will help us to find the error if we don't change these values like this.
> >> >
> >>
> >> And actually it help us find another issue that when availble_memroy
> >> is too small, the thresh and bg_thresh will be 0, that's absolutely
> >> wrong.
> >
> > Why is it wrong?
> > --
> 
> For example, the writeback threads will be wakeup on every write.
> I don't think it is meaningful to wakeup the writeback thread when the
> dirty pages is very low.

Well, this is a corner situation when we are out of memory basically.
Doing a wake up on the flusher is the least of your problem. So _why_
exactly is this is problem?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
