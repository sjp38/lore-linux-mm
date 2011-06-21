Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5951C90013A
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 16:01:26 -0400 (EDT)
Message-ID: <4E00F88F.2080603@redhat.com>
Date: Tue, 21 Jun 2011 16:01:19 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: completely disable THP by transparent_hugepage=never
References: <1308587683-2555-1-git-send-email-amwang@redhat.com> <20110620165844.GA9396@suse.de> <4DFF7E3B.1040404@redhat.com> <4DFF7F0A.8090604@redhat.com> <4DFF8106.8090702@redhat.com> <4DFF8327.1090203@redhat.com> <4DFF84BB.3050209@redhat.com> <4DFF8848.2060802@redhat.com> <20110620182558.GF4749@redhat.com> <20110620192117.GG20843@redhat.com> <4E00192E.70901@redhat.com>
In-Reply-To: <4E00192E.70901@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On 06/21/2011 12:08 AM, Cong Wang wrote:

> The thing is that we can save ~10K by adding 3 lines of code as this
> patch showed, where else in kernel can you save 10K by 3 lines of code?
> (except some kfree() cases, of course) So, again, why not have it? ;)

Because we'll end up with hundreds of lines of code, just
to save under 1MB of memory.  Which ends up not being saved
at all, because people will still give their kdump kernel
128MB :)

The only really big gain you are likely to get is making
sure all the per-cpu memory is not allocated in the kdump
kernel (which is booted with 1 cpu).

That is a big, multi-MB, optimization that can be implemented
in one place.  Large savings for a localized change, so you
actually have a chance of having the changes accepted upstream.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
