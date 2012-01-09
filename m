Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 51AFD6B005A
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 18:49:55 -0500 (EST)
Received: by ggni2 with SMTP id i2so2255028ggn.14
        for <linux-mm@kvack.org>; Mon, 09 Jan 2012 15:49:54 -0800 (PST)
Message-ID: <4F0B7D1F.7040802@gmail.com>
Date: Mon, 09 Jan 2012 18:49:51 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] make swapin readahead skip over holes
References: <20120109181023.7c81d0be@annuminas.surriel.com>
In-Reply-To: <20120109181023.7c81d0be@annuminas.surriel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

(1/9/12 6:10 PM), Rik van Riel wrote:
> Ever since abandoning the virtual scan of processes, for scalability
> reasons, swap space has been a little more fragmented than before.
> This can lead to the situation where a large memory user is killed,
> swap space ends up full of "holes" and swapin readahead is totally
> ineffective.
>
> On my home system, after killing a leaky firefox it took over an
> hour to page just under 2GB of memory back in, slowing the virtual
> machines down to a crawl.
>
> This patch makes swapin readahead simply skip over holes, instead
> of stopping at them.  This allows the system to swap things back in
> at rates of several MB/second, instead of a few hundred kB/second.

If I understand correctly, this patch have

Pros
  - increase IO throughput
Cons
  - increase a risk to pick up unrelated swap entries by swap readahead


The changelog explained former but doesn't explained latter. I'm a bit
hesitate now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
