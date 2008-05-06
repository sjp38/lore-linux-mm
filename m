Date: Mon, 5 May 2008 20:43:18 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [-mm][PATCH 4/5] core of reclaim throttle
Message-ID: <20080505204318.3f95c83c@bree.surriel.com>
In-Reply-To: <2f11576a0805051523h730fce0foa51f1fdbf9c46cbe@mail.gmail.com>
References: <20080504201343.8F52.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080504215819.8F5E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080504221043.8F64.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080505175142.7de3f27b@cuia.bos.redhat.com>
	<2f11576a0805051523h730fce0foa51f1fdbf9c46cbe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 6 May 2008 07:23:18 +0900
"KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com> wrote:

> hmmm, AFAIK,
> on current kernel, sometimes __GFP_IO task wait for non __GFP_IO task
> by lock_page().
> Is this wrong?

This is fine.

The problem is adding a code path that causes non __GFP_IO tasks to
wait on __GFP_IO tasks.  Then you can have a deadlock.
 
> therefore my patch care only recursive reclaim situation.
> I don't object to your opinion. but I hope understand exactly your opinion.

I believe not all non __GFP_IO or non __GFP_FS calls are recursive
reclaim, but there are some other code paths too.  For example from
fs/buffer.c

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
