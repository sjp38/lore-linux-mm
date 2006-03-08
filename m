From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: yield during swap prefetching
Date: Wed, 8 Mar 2006 13:12:50 +1100
References: <200603081013.44678.kernel@kolivas.org> <200603081228.05820.kernel@kolivas.org> <1141783711.767.121.camel@mindpipe>
In-Reply-To: <1141783711.767.121.camel@mindpipe>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200603081312.51058.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Revell <rlrevell@joe-job.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Mar 2006 01:08 pm, Lee Revell wrote:
> On Wed, 2006-03-08 at 12:28 +1100, Con Kolivas wrote:
> > I can't distinguish between when cpu activity is important (game) and
> > when it is not (compile), and assuming worst case scenario and not doing
> > any swap prefetching is my intent. I could add cpu accounting to
> > prefetch_suitable() instead, but that gets rather messy and yielding
> > achieves the same endpoint.
>
> Shouldn't the game be running with RT priority or at least at a low nice
> value?

No way. Games run nice 0 SCHED_NORMAL.

Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
