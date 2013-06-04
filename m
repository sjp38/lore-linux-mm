Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id D31616B0032
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 11:24:39 -0400 (EDT)
Message-ID: <51AE06B6.3030009@sr71.net>
Date: Tue, 04 Jun 2013 08:24:38 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [v5][PATCH 6/6] mm: vmscan: drain batch list during long operations
References: <20130603200202.7F5FDE07@viggo.jf.intel.com> <20130603200210.259954C3@viggo.jf.intel.com> <20130604060553.GF14719@blaptop>
In-Reply-To: <20130604060553.GF14719@blaptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com

On 06/03/2013 11:05 PM, Minchan Kim wrote:
>> > This ensures that we drain the batch if we are about to perform a
>> > pageout() or congestion_wait(), either of which will take some
>> > time.  We expect this to help mitigate the worst of the latency
>> > increase that the batching could cause.
> Nice idea but I could see drain before pageout but congestion_wait?

That comment managed to bitrot a bit :(

The first version of these had the drain before pageout() only.  Then,
Mel added a congestion_wait() call, and I modified the series to also
drain there.  But, some other patches took the congestion_wait() back
out, so I took that drain back out.

I _believe_ the only congestion_wait() left in there is a cgroup-related
one that we didn't think would cause very much harm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
