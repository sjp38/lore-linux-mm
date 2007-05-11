Date: Fri, 11 May 2007 09:54:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memory hotremove patch take 2 [03/10] (drain all pages)
Message-Id: <20070511095445.6f357d29.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0705101105350.10002@schroedinger.engr.sgi.com>
References: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
	<20070509120337.B90A.Y-GOTO@jp.fujitsu.com>
	<Pine.LNX.4.64.0705101105350.10002@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: y-goto@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@osdl.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Thu, 10 May 2007 11:07:08 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 9 May 2007, Yasunori Goto wrote:
> 
> > This patch add function drain_all_pages(void) to drain all 
> > pages on per-cpu-freelist.
> > Page isolation will catch them in free_one_page.
> 
> This is only draining the pcps of the local processor. I would think 
> that you need to drain all other processors pcps of this zone as well. And 
> there is no need to drain this processors pcps of other zones.
> 

As Mel-san pointed, -mm has drain_all_local_pages(). We'll use it.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
