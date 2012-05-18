Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 7243F6B0082
	for <linux-mm@kvack.org>; Fri, 18 May 2012 11:07:50 -0400 (EDT)
Message-ID: <4FB665B8.8000300@redhat.com>
Date: Fri, 18 May 2012 11:07:36 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 0/5] refault distance-based file cache sizing
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org> <4FB33A4E.1010208@gmail.com> <20120516065132.GC1769@cmpxchg.org> <4FB3A416.9010703@gmail.com> <20120517210849.GE1800@cmpxchg.org> <4FB5C5A7.6080000@gmail.com>
In-Reply-To: <4FB5C5A7.6080000@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nai.xia@gmail.com
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/17/2012 11:44 PM, Nai Xia wrote:

> But I do think that Clock-pro deserves its credit, since after all
> it's that research work firstly brought the idea of "refault/reuse
> distance" to the kernel community.

The ARC people did that, too.

> Further more, it's also good
> to let the researchers and the community to together have some
> brain-storm of this problem if it's really hard to deal with in
> reality.

How much are researchers interested in the real world
constraints that OS developers have to deal with?

Often scalability is as much of a goal as being good
at selecting the right page to replace...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
