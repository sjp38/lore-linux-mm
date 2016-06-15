Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id D835E6B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 20:43:29 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id x6so11810744oif.0
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 17:43:29 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id x80si36239750ioi.78.2016.06.14.17.43.28
        for <linux-mm@kvack.org>;
        Tue, 14 Jun 2016 17:43:29 -0700 (PDT)
Date: Wed, 15 Jun 2016 09:43:34 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 0/3] per-process reclaim
Message-ID: <20160615004334.GB17127@bbox>
References: <1465804259-29345-1-git-send-email-minchan@kernel.org>
 <575E9DE8.4050200@hisilicon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <575E9DE8.4050200@hisilicon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Feng <puck.chen@hisilicon.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Redmond <u93410091@gmail.com>, "ZhaoJunmin Zhao(Junmin)" <zhaojunmin@huawei.com>, Vinayak Menon <vinmenon@codeaurora.org>, Juneho Choi <juno.choi@lge.com>, Sangwoo Park <sangwoo2.park@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>

Hi Chen,

On Mon, Jun 13, 2016 at 07:50:00PM +0800, Chen Feng wrote:
> Hi Minchan,
> 
> On 2016/6/13 15:50, Minchan Kim wrote:
> > Hi all,
> > 
> > http://thread.gmane.org/gmane.linux.kernel/1480728
> > 
> > I sent per-process reclaim patchset three years ago. Then, last
> > feedback from akpm was that he want to know real usecase scenario.
> > 
> > Since then, I got question from several embedded people of various
> > company "why it's not merged into mainline" and heard they have used
> > the feature as in-house patch and recenlty, I noticed android from
> > Qualcomm started to use it.
> > 
> > Of course, our product have used it and released it in real procuct.
> > 
> > Quote from Sangwoo Park <angwoo2.park@lge.com>
> > Thanks for the data, Sangwoo!
> > "
> > - Test scenaro
> >   - platform: android
> >   - target: MSM8952, 2G DDR, 16G eMMC
> >   - scenario
> >     retry app launch and Back Home with 16 apps and 16 turns
> >     (total app launch count is 256)
> >   - result:
> > 			  resume count   |  cold launching count
> > -----------------------------------------------------------------
> >  vanilla           |           85        |          171
> >  perproc reclaim   |           184       |           72
> > "
> > 
> > Higher resume count is better because cold launching needs loading
> > lots of resource data which takes above 15 ~ 20 seconds for some
> > games while successful resume just takes 1~5 second.
> > 
> > As perproc reclaim way with new management policy, we could reduce
> > cold launching a lot(i.e., 171-72) so that it reduces app startup
> > a lot.
> > 
> > Another useful function from this feature is to make swapout easily
> > which is useful for testing swapout stress and workloads.
> > 
> Thanks Minchan.
> 
> Yes, this is useful interface when there are memory pressure and let the userspace(Android)
> to pick process for reclaim. We also take there series into our platform.
> 
> But I have a question on the reduce app startup time. Can you also share your
> theory(management policy) on how can the app reduce it's startup time?

What I meant about start-up time is as follows,

If a app is killed, it should launch from start so if it was the game app,
it should load lots of resource file which takes a long time.
However, if the game was not killed, we can enjoy the game without cold
start so it is very fast startup.

Sorry for confusing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
