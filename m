Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id E11856B004D
	for <linux-mm@kvack.org>; Sat, 24 Mar 2012 12:44:39 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so4417103bkw.14
        for <linux-mm@kvack.org>; Sat, 24 Mar 2012 09:44:39 -0700 (PDT)
Date: Sat, 24 Mar 2012 20:43:35 +0400
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [PATCH 07/10] um: Should hold tasklist_lock while traversing
 processes
Message-ID: <20120324164335.GA4955@lizard>
References: <20120324102609.GA28356@lizard>
 <20120324103030.GG29067@lizard>
 <1332593303.16159.28.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1332593303.16159.28.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Russell King <linux@arm.linux.org.uk>, Mike Frysinger <vapier@gentoo.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Richard Weinberger <richard@nod.at>, Paul Mundt <lethal@linux-sh.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, John Stultz <john.stultz@linaro.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-mm@kvack.org

On Sat, Mar 24, 2012 at 01:48:23PM +0100, Peter Zijlstra wrote:
> On Sat, 2012-03-24 at 14:30 +0400, Anton Vorontsov wrote:
> > Traversing the tasks requires holding tasklist_lock, otherwise it
> > is unsafe. 
> 
> No it doesn't, it either requires tasklist_lock or rcu_read_lock().

Well, currently the code does neither. :-)

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
