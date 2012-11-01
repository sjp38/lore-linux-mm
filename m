Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 7B83E6B0085
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 18:25:53 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so2244608pad.14
        for <linux-mm@kvack.org>; Thu, 01 Nov 2012 15:25:52 -0700 (PDT)
Date: Thu, 1 Nov 2012 15:25:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: zram OOM behavior
In-Reply-To: <CAA25o9TvZxoLgnt0YEFtAP8D-mTyL6QupiLTR65uFByTkt3TxA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1211011524540.26123@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1210222257580.22198@chino.kir.corp.google.com> <CAA25o9ScWUsRr2ziqiEt9U9UvuMuYim+tNpPCyN88Qr53uGhVQ@mail.gmail.com> <alpine.DEB.2.00.1210291158510.10845@chino.kir.corp.google.com> <CAA25o9Rk_C=jaHJwWQ8TJL0NF5_Xv2umwxirtdugF6w3rHruXg@mail.gmail.com>
 <20121030001809.GL15767@bbox> <CAA25o9R0zgW74NRGyZZHy4cFbfuVEmHWVC=4O7SuUjywN+Uvpw@mail.gmail.com> <alpine.DEB.2.00.1210292239290.13203@chino.kir.corp.google.com> <CAA25o9Tp5J6-9JzwEfcZJ4dHQCEKV9_GYO0ZQ05Ttc3QWP=5_Q@mail.gmail.com> <20121031005738.GM15767@bbox>
 <alpine.DEB.2.00.1210311151341.8809@chino.kir.corp.google.com> <20121101024316.GB24883@bbox> <alpine.DEB.2.00.1210312140090.17607@chino.kir.corp.google.com> <CAA25o9SdQ7e5w8=W0faz82nZ7_3N7xbbExKQe0-HsU87hs2MPA@mail.gmail.com>
 <alpine.DEB.2.00.1211011448490.19373@chino.kir.corp.google.com> <CAA25o9TvZxoLgnt0YEFtAP8D-mTyL6QupiLTR65uFByTkt3TxA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>

On Thu, 1 Nov 2012, Luigi Semenzato wrote:

> I see.  But then I am wondering: if there is no limit to the number of
> threads that can access the reserved memory, then is it possible that
> that memory will be exhausted?  Is the size of the reserved memory
> based on heuristics then?
> 

We assume that processes with access to memory reserves will eventually 
exit and free their memory, that has always been the case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
