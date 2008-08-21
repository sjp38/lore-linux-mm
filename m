Received: by rv-out-0708.google.com with SMTP id f25so701238rvb.26
        for <linux-mm@kvack.org>; Thu, 21 Aug 2008 00:36:00 -0700 (PDT)
Message-ID: <2f11576a0808210036icd9b61eue58049f15381bcc8@mail.gmail.com>
Date: Thu, 21 Aug 2008 16:36:00 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/2] Show quicklist at meminfo
In-Reply-To: <20080820113559.f559a411.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080820200607.12ED.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080820113559.f559a411.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, tokunaga.keiich@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> quicklist_total_size() is racy against cpu hotplug.  That's OK for
> /proc/meminfo purposes (occasional transient inaccuracy?), but will it
> crash?  Not in the current implementation of per_cpu() afaict, but it
> might crash if we ever teach cpu hotunplug to free up the percpu
> resources.

First, Quicklist doesn't concern to cpu hotplug at all.
it is another quicklist problem.

Next, I think it doesn't cause crash. but I haven't any test.
So, I'll test cpu hotplug/unplug testing today.

I'll report result tommorow.

> I see no cpu hotplug handling in the quicklist code.  Do we leak all
> the hot-unplugged CPU's pages?

Yes.


Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
