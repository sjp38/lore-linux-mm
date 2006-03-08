Date: Tue, 7 Mar 2006 17:23:37 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] mm: yield during swap prefetching
Message-Id: <20060307172337.1d97cd80.akpm@osdl.org>
In-Reply-To: <200603081212.03223.kernel@kolivas.org>
References: <200603081013.44678.kernel@kolivas.org>
	<200603081151.13942.kernel@kolivas.org>
	<20060307171134.59288092.akpm@osdl.org>
	<200603081212.03223.kernel@kolivas.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

Con Kolivas <kernel@kolivas.org> wrote:
>
> > but, but.  If prefetching is prefetching stuff which that game will soon
> > use then it'll be an aggregate improvement.  If prefetch is prefetching
> > stuff which that game _won't_ use then prefetch is busted.  Using yield()
> > to artificially cripple kprefetchd is a rather sad workaround isn't it?
> 
> It's not the stuff that it prefetches that's the problem; it's the disk 
> access.

But the prefetch code tries to avoid prefetching when the disk is otherwise
busy (or it should - we discussed that a bit a while ago).

Sorry, I'm not trying to be awkward here - I think that nobbling prefetch
when there's a lot of CPU activity is just the wrong thing to do and it'll
harm other workloads.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
