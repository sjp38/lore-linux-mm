Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 893276B002C
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 18:32:18 -0500 (EST)
Date: Wed, 29 Feb 2012 15:32:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: extend prefault helpers to fault in more than
 PAGE_SIZE
Message-Id: <20120229153216.8c3ae31d.akpm@linux-foundation.org>
In-Reply-To: <20120229231453.GA6662@phenom.ffwll.local>
References: <20120224124003.93780408.akpm@linux-foundation.org>
	<1330524211-2698-1-git-send-email-daniel.vetter@ffwll.ch>
	<20120229150146.2cc64fac.akpm@linux-foundation.org>
	<20120229231453.GA6662@phenom.ffwll.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Thu, 1 Mar 2012 00:14:53 +0100
Daniel Vetter <daniel@ffwll.ch> wrote:

> I'll redo this patch by adding _multipage versions of these 2 functions
> for i915.

OK, but I hope "for i915" doesn't mean "private to"!  Put 'em in
pagemap.h, for maintenance reasons and because they are generic.

Making them inline is a bit sad, but that's OK for now - they have few
callsites.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
