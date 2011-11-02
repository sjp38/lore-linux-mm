Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8B5506B0069
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 11:59:39 -0400 (EDT)
Date: Wed, 2 Nov 2011 16:55:05 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: Issue with core dump
Message-ID: <20111102155505.GA30500@redhat.com>
References: <CAGr+u+zkPiZpGefstcbJv_cj929icWKXbqFy1uR22Hns1hzFeQ@mail.gmail.com> <20111101152320.GA30466@redhat.com> <CAGr+u+wgAYVWgdcG6o+6F0mDzuyNzoOxvsFwq0dMsR3JNnZ-cA@mail.gmail.com> <20111102153146.GC12543@dhcp-172-17-108-109.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111102153146.GC12543@dhcp-172-17-108-109.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: trisha yad <trisha1march@gmail.com>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, rientjes@google.com, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rusty Russell <rusty@rustcorp.com.au>

On 11/02, Tejun Heo wrote:
>
> Also, the time between do_user_fault() and actual core dumping isn't
> the important factor here.  do_user_fault() directly triggers delivery
> of SIGSEGV (or BUS) and signal delivery will immediately deliver
> SIGKILL to all other threads in the process,

Not really, note the "if (!sig_kernel_coredump(sig))" check. And this
is what we can improve. But this is not simple, and personally I think
doesn't worth the trouble.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
