Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 72BE66B005C
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 11:51:28 -0400 (EDT)
Message-ID: <51DED47A.8090008@intel.com>
Date: Thu, 11 Jul 2013 08:51:22 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/5] mm, page_alloc: support multiple pages allocation
References: <1372840460-5571-1-git-send-email-iamjoonsoo.kim@lge.com> <1372840460-5571-2-git-send-email-iamjoonsoo.kim@lge.com> <51DDE5BA.9020800@intel.com> <20130711010248.GB7756@lge.com> <51DE44CC.2070700@sr71.net> <20130711061201.GA2400@lge.com>
In-Reply-To: <20130711061201.GA2400@lge.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Dave Hansen <dave@sr71.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/10/2013 11:12 PM, Joonsoo Kim wrote:
>> > I'd also like to see some scalability numbers on this.  How do your
>> > tests look when all the CPUs on the system are hammering away?
> What test do you mean?
> Please elaborate on this more

Your existing tests looked single-threaded.  That's certainly part of
the problem.  Will your patches have implications for larger systems,
though?  How much do your patches speed up or slow things down if we
have many allocations proceeding on many CPUs in parallel?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
