Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 83C756B0069
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 08:46:15 -0500 (EST)
Subject: Re: [patch] mm: memcg: shorten preempt-disabled section around
 event checks
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <20111121110954.GE1771@redhat.com>
References: <20111121110954.GE1771@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 21 Nov 2011 08:46:07 -0500
Message-ID: <1321883167.20742.4.camel@frodo>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Yong Zhang <yong.zhang0@gmail.com>, Luis Henriques <henrix@camandro.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2011-11-21 at 12:09 +0100, Johannes Weiner wrote:
> -rt ran into a problem with the soft limit spinlock inside the
> non-preemptible section, because that is sleeping inside an atomic
> context.  But I think it makes sense for vanilla, too, to keep the
> non-preemptible section as short as possible.  Also, -3 lines.
> 

Johannes,

Thanks for this patch. It is very much appreciated by us -rt folks :)

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
