Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 94B13600786
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 04:59:53 -0500 (EST)
Date: Tue, 1 Dec 2009 10:59:47 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/9] ksm: let shared pages be swappable
Message-ID: <20091201095947.GM30235@random.random>
References: <20091201181633.5C31.A69D9226@jp.fujitsu.com>
 <20091201093738.GL30235@random.random>
 <20091201184535.5C37.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091201184535.5C37.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Dec 01, 2009 at 06:46:06PM +0900, KOSAKI Motohiro wrote:
> Ah, well. please wait a bit. I'm under reviewing Larry's patch. I don't
> dislike your idea. last mail only pointed out implementation thing.

Yep thanks for pointing it out. It's an implementation thing I don't
like. The VM should not ever touch ptes when there's light VM pressure
and plenty of unmapped clean cache available, but I'm ok if others
disagree and want to keep it that way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
