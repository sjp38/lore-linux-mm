Date: Wed, 19 Mar 2008 15:07:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [0/2] vmalloc: Add /proc/vmallocinfo to display mappings
Message-Id: <20080319150704.d3f090e6.akpm@linux-foundation.org>
In-Reply-To: <20080319111943.0E1B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080318222701.788442216@sgi.com>
	<20080319111943.0E1B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Mar 2008 11:23:30 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>
> > The following two patches implement /proc/vmallocinfo. /proc/vmallocinfo
> > displays data about the vmalloc allocations. The second patch introduces
> > a tracing feature that allows to display the function that allocated the
> > vmalloc area.
> > 
> > Example:
> > 
> > cat /proc/vmallocinfo

argh, please don't top-post.

(undoes it)

>
> Hi
> 
> Great.
> it seems very useful.
> and, I found no bug.
> 
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


I was just about to ask whether we actually need the feature - I don't
recall ever having needed it, nor do I recall seeing anyone else need it.

Why is it useful?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
