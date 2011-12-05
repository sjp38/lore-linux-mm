Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id A8BEA6B004F
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 11:14:45 -0500 (EST)
Date: Mon, 5 Dec 2011 17:14:43 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Question about __zone_watermark_ok: why there is a "+ 1" in
 computing free_pages?
Message-ID: <20111205161443.GA20663@tiehlicka.suse.cz>
References: <CAKXJSOHu+sQ1NeMsRvFyp2GYoB6g+50boUu=-QvbxxjcqgOAVA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKXJSOHu+sQ1NeMsRvFyp2GYoB6g+50boUu=-QvbxxjcqgOAVA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On Fri 25-11-11 09:21:35, Wang Sheng-Hui wrote:
> In line 1459, we have "free_pages -= (1 << order) + 1;".
> Suppose allocating one 0-order page, here we'll get
>     free_pages -= 1 + 1
> I wonder why there is a "+ 1"?

Good spot. Check the patch bellow.
---
