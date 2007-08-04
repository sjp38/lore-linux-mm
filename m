Received: by ug-out-1314.google.com with SMTP id c2so618727ugf
        for <linux-mm@kvack.org>; Sat, 04 Aug 2007 10:04:38 -0700 (PDT)
Date: Sat, 4 Aug 2007 19:02:10 +0200
From: Diego Calleja <diegocg@gmail.com>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-Id: <20070804190210.8b1530dd.diegocg@gmail.com>
In-Reply-To: <20070804163733.GA31001@elte.hu>
References: <20070803123712.987126000@chello.nl>
	<alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org>
	<20070804063217.GA25069@elte.hu>
	<20070804070737.GA940@elte.hu>
	<20070804103347.GA1956@elte.hu>
	<alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>
	<20070804163733.GA31001@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk
List-ID: <linux-mm.kvack.org>

El Sat, 4 Aug 2007 18:37:33 +0200, Ingo Molnar <mingo@elte.hu> escribio:

> thousands of applications. So for most file workloads we give Windows a 
> 20%-30% performance edge, for almost nothing. (for RAM-starved kernel 
> builds the performance difference between atime and noatime+nodiratime 
> setups is more on the order of 40%)

Just curious - do you have numbers with relatime?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
