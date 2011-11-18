Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1BB3D6B0069
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 01:52:00 -0500 (EST)
Date: Thu, 17 Nov 2011 22:52:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: account reaped page cache on inode cache pruning
Message-Id: <20111117225202.3535aba3.akpm@linux-foundation.org>
In-Reply-To: <4EC5FE6A.3080003@openvz.org>
References: <20111116134713.8933.34389.stgit@zurg>
	<20111117162322.1c3e3d05.akpm@linux-foundation.org>
	<4EC5FE6A.3080003@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>

On Fri, 18 Nov 2011 10:42:50 +0400 Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Do we really need separate on-stack reclaim_state structure with single field?
> Maybe replace it with single long (or even unsigned int) .reclaimed_pages field on task_struct
> and account reclaimed pages unconditionally.

I don't think it matters a lot - it's either a temporary pointer on the
stack or a permanent space consumption in the task_struct.

The way thing are at present we can easily add new fields if needed.  I
don't think we've ever done that though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
