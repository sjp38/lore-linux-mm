Date: Thu, 15 Mar 2007 19:20:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] Lumpy Reclaim V5
Message-Id: <20070315192038.82933a2f.akpm@linux-foundation.org>
In-Reply-To: <exportbomb.1173723760@pinky>
References: <exportbomb.1173723760@pinky>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, 12 Mar 2007 18:22:45 +0000 Andy Whitcroft <apw@shadowen.org> wrote:

> Following this email are three patches which represent the
> current state of the lumpy reclaim patches; collectively lumpy V5.

So where do we stand with this now?    Does it make anything get better?

I (continue to) think that if this is to be truly useful, we need some way
of using it from kswapd to keep a certain minimum number of order-1,
order-2, etc pages in the freelists.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
