Date: Fri, 11 May 2007 09:53:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memory hotremove patch take 2 [03/10] (drain all pages)
Message-Id: <20070511095321.6559932c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0705101634350.3786@skynet.skynet.ie>
References: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
	<20070509120337.B90A.Y-GOTO@jp.fujitsu.com>
	<Pine.LNX.4.64.0705101634350.3786@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: y-goto@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@osdl.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 10 May 2007 16:35:37 +0100 (IST)
Mel Gorman <mel@csn.ul.ie> wrote:

> On Wed, 9 May 2007, Yasunori Goto wrote:
> 
> > This patch add function drain_all_pages(void) to drain all
> > pages on per-cpu-freelist.
> > Page isolation will catch them in free_one_page.
> >
> 
> Is this significantly different to what drain_all_local_pages() currently 
> does?
> 

no difference. this duplicating it..... thank you for pointing out.
Maybe I missed this because this func only exists in -mm.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
