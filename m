Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D05DB6B0005
	for <linux-mm@kvack.org>; Mon, 16 May 2016 21:27:23 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 203so3496807pfy.2
        for <linux-mm@kvack.org>; Mon, 16 May 2016 18:27:23 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id d7si465188pfc.187.2016.05.16.18.27.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 18:27:23 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id y7so208091pfb.0
        for <linux-mm@kvack.org>; Mon, 16 May 2016 18:27:23 -0700 (PDT)
Date: Tue, 17 May 2016 10:27:12 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 08/12] zsmalloc: introduce zspage structure
Message-ID: <20160517012712.GA497@swordfish>
References: <1462760433-32357-1-git-send-email-minchan@kernel.org>
 <1462760433-32357-9-git-send-email-minchan@kernel.org>
 <20160516030941.GD504@swordfish>
 <20160517011418.GB31335@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160517011418.GB31335@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (05/17/16 10:14), Minchan Kim wrote:
[..]
> > can we also switch create_cache() to errnos? I just like a bit
> > better
> > 		return -ENOMEM;
> > 	else
> > 		return 0;
> > 
> > than
> > 
> > 		return 1;
> > 	else
> > 		return 0;
> > 
> 
> Hmm, of course, I can do it easily.
> But zs_create_pool returns NULL without error propagation from sub
> functions so I don't see any gain from returning errno from
> create_cache. I don't mean I hate it but just need a justificaion
> to persuade grumpy me.

:) not married to those errnos. can skip it.

> > > +static struct zspage *isolate_zspage(struct size_class *class, bool source)
> > >  {
> > > +	struct zspage *zspage;
> > > +	enum fullness_group fg[2] = {ZS_ALMOST_EMPTY, ZS_ALMOST_FULL};
> > > +	if (!source) {
> > > +		fg[0] = ZS_ALMOST_FULL;
> > > +		fg[1] = ZS_ALMOST_EMPTY;
> > > +	}
> > > +
> > > +	for (i = 0; i < 2; i++) {
> > 
> > sorry, why not "for (i = ZS_ALMOST_EMPTY; i <= ZS_ALMOST_FULL ..." ?
> 
> For source zspage, the policy is to find a fragment object from ZS_ALMOST_EMPTY.
> For target zspage, the policy is to find a fragment object from ZS_ALMOST_FULL.
> 
> Do I misunderstand your question?

ahhh... sorry, it's just me being silly. I got it now.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
