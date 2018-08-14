Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E22CC6B000A
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 20:48:50 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id g18-v6so10590264pfh.20
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 17:48:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u2-v6sor4246407pgi.227.2018.08.13.17.48.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 Aug 2018 17:48:49 -0700 (PDT)
Date: Tue, 14 Aug 2018 09:51:55 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zsmalloc: fix linking bug in init_zspage
Message-ID: <20180814005155.GB20631@jagdpanzerIV>
References: <20180810002817.2667-1-zhouxianrong@tom.com>
 <20180813060549.GB64836@rodete-desktop-imager.corp.google.com>
 <20180813105536.GA435@jagdpanzerIV>
 <20180814002416.GA34280@rodete-desktop-imager.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180814002416.GA34280@rodete-desktop-imager.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, zhouxianrong <zhouxianrong@tom.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ngupta@vflare.org, zhouxianrong <zhouxianrong@huawei.com>

Hi Minchan,

On (08/14/18 09:24), Minchan Kim wrote:
> > Any thoughts?
>
> If we want a refactoring, I'm not against but description said it tiggered
> BUG_ON on zs_map_object rarely. That means it should be stable material
> and need more description to understand. Please be more specific with
> some example.

I don't have any BUG_ON on hands. Would be great if zhouxianrong could
post some backtraces or more info/explanation.

> The reason I'm hesitating is zsmalloc moves ZS_FULL group
> when the zspage->inuse is equal to class->objs_per_zspage so I thought
> it shouldn't allocate last partial object.

Maybe, allocating last partial object does look a bit hacky - it's not a
valid object anyway, but I'm not suggesting that we need to change it.
Let's hear from zhouxianrong.

	-ss
