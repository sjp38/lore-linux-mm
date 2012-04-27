Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id CE91B6B0044
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 19:40:46 -0400 (EDT)
Date: Fri, 27 Apr 2012 16:40:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] proc: report file/anon bit in /proc/pid/pagemap
Message-Id: <20120427164044.c883d390.akpm@linux-foundation.org>
In-Reply-To: <4F9AA11E.3040800@parallels.com>
References: <4F91BC8A.9020503@parallels.com>
	<20120427123901.2132.47969.stgit@zurg>
	<4F9AA11E.3040800@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Matt Mackall <mpm@selenic.com>

On Fri, 27 Apr 2012 17:37:34 +0400
Pavel Emelyanov <xemul@parallels.com> wrote:

> > Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> > Cc: Pavel Emelyanov <xemul@parallels.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Rik van Riel <riel@redhat.com>
> 
> Acked-by: Pavel Emelyanov <xemul@parallels.com>

hm, I'd have thought this should be From:Pavel and certainly
Signed-off-by:Pavel, but I'll let you guys decide.

Rik acked the earlier version and that isn't reflected here.  I never
know what to do about this.  I usually play it safe and assume that a
change in the patch erases the ack.

Please cc the original pagemap author (Matt Mackall <mpm@selenic.com>)
on these patches.  He's sometimes useful ;)

The patches looked nice to me, but as it appears that Pavel is unhappy
with [2/2] I shall tip this patchset into my bitbucket and shall await
the next rev, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
