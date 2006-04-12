Date: Wed, 12 Apr 2006 16:06:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] support for panic at OOM
Message-Id: <20060412160619.31a3c027.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060411235907.6a59ecba.akpm@osdl.org>
References: <20060412155301.10d611ca.kamezawa.hiroyu@jp.fujitsu.com>
	<20060411235907.6a59ecba.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, clameter@engr.sgi.com, riel@redhat.com, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 11 Apr 2006 23:59:07 -0700
Andrew Morton <akpm@osdl.org> wrote:

> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > This patch adds a feature to panic at OOM, oom_die.
> 
> Makes sense I guess.
> 
Thanks,

> > @@ -718,6 +719,14 @@ static ctl_table vm_table[] = {
> >  		.proc_handler	= &proc_dointvec,
> >  	},
> >  	{
> > +		.ctl_name	= VM_OOM_DIE,
> > +		.procname	= "oom_die",
> 
> I'd suggest it be called "panic_on_oom".  Like the current panic_on_oops.
> 
I'll chage.

> > +int sysctl_oom_die = 0;
> 
> The initialisation is unneeded.
> 
Okay,


> > +		if (sysctl_oom_die)
> > +			oom_die();
> 
> I don't think we need a separate function for this?
> 
Hmm.. okay. I'll put panic("Panic: out of memory: panic_on_oom is 1.") directly.

> Please document the new sysctl in Documentation/sysctl/.
> 
I'll do.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
