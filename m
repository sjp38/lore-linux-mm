Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 8F75D6B0032
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 20:26:52 -0400 (EDT)
Date: Tue, 16 Jul 2013 09:26:52 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 1/5] mm, page_alloc: support multiple pages allocation
Message-ID: <20130716002652.GA2430@lge.com>
References: <1372840460-5571-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1372840460-5571-2-git-send-email-iamjoonsoo.kim@lge.com>
 <51DDE5BA.9020800@intel.com>
 <20130711010248.GB7756@lge.com>
 <51DE44CC.2070700@sr71.net>
 <20130711061201.GA2400@lge.com>
 <51DED47A.8090008@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51DED47A.8090008@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave@sr71.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jul 11, 2013 at 08:51:22AM -0700, Dave Hansen wrote:
> On 07/10/2013 11:12 PM, Joonsoo Kim wrote:
> >> > I'd also like to see some scalability numbers on this.  How do your
> >> > tests look when all the CPUs on the system are hammering away?
> > What test do you mean?
> > Please elaborate on this more
> 
> Your existing tests looked single-threaded.  That's certainly part of
> the problem.  Will your patches have implications for larger systems,
> though?  How much do your patches speed up or slow things down if we
> have many allocations proceeding on many CPUs in parallel?

Hello.

Okay, I will do that and attach the result to v2.

Thanks.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
