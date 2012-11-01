Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id BE1736B00AA
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 17:48:06 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so2225800pad.14
        for <linux-mm@kvack.org>; Thu, 01 Nov 2012 14:48:06 -0700 (PDT)
Date: Thu, 1 Nov 2012 14:48:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: zram OOM behavior
In-Reply-To: <CAA25o9Qsm=Ly1CqoEwhC1wtayAx6S7att-+g4u+g0nkASNKLQA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1211011446270.19373@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1210291158510.10845@chino.kir.corp.google.com> <CAA25o9Rk_C=jaHJwWQ8TJL0NF5_Xv2umwxirtdugF6w3rHruXg@mail.gmail.com> <20121030001809.GL15767@bbox> <CAA25o9R0zgW74NRGyZZHy4cFbfuVEmHWVC=4O7SuUjywN+Uvpw@mail.gmail.com>
 <alpine.DEB.2.00.1210292239290.13203@chino.kir.corp.google.com> <CAA25o9Tp5J6-9JzwEfcZJ4dHQCEKV9_GYO0ZQ05Ttc3QWP=5_Q@mail.gmail.com> <20121031005738.GM15767@bbox> <alpine.DEB.2.00.1210311151341.8809@chino.kir.corp.google.com> <20121101024316.GB24883@bbox>
 <alpine.DEB.2.00.1210312140090.17607@chino.kir.corp.google.com> <20121101082814.GL3888@suse.de> <CAA25o9RN4poSQj1z-xka0HQib-2-9+Q_O8Wa+EggBQ1OXUvMUQ@mail.gmail.com> <CAA25o9Qsm=Ly1CqoEwhC1wtayAx6S7att-+g4u+g0nkASNKLQA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>

On Thu, 1 Nov 2012, Luigi Semenzato wrote:

> So which one should I try first, David's change or Mel's?
> 
> Does Mel's change take into account the fact that the exiting process
> is already deep into do_exit() (exit_mm() to be precise) when it tries
> to allocate?
> 

Mel's patch is addressing a separate issue since you've already proven 
that your problem is calling the oom killer which wouldn't occur if your 
thread had SIGKILL prior to Mel's patch.  It would allow my suggested 
workaround of killing the hung task to end the livelock, though, but that 
shouldn't be needed after my patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
