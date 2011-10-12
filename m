Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9F1046B002E
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 10:44:47 -0400 (EDT)
Date: Wed, 12 Oct 2011 16:40:48 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch resend] oom: thaw threads if oom killed thread is
	frozen before deferring
Message-ID: <20111012144047.GB30223@redhat.com>
References: <alpine.DEB.2.00.1110071954040.13992@chino.kir.corp.google.com> <20111011191603.GA12751@redhat.com> <alpine.DEB.2.00.1110111628200.5236@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1110111628200.5236@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On 10/11, David Rientjes wrote:
>
> On Tue, 11 Oct 2011, Oleg Nesterov wrote:
>
> > David. Could you also resend you patches which remove the (imho really
> > annoying) mm->oom_disable_count? Feel free to add my ack or reviewed-by.
> >
>
> As far as I know (I can't confirm because userweb.kernel.org is still
> down), oom-remove-oom_disable_count.patch is still in the -mm tree.  It
> was merged September 2 so I believe it's 3.2 material.

Ah, great. Somehow I thought it was missed.

Thanks David,

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
