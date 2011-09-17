Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 614E79000BD
	for <linux-mm@kvack.org>; Sat, 17 Sep 2011 14:34:06 -0400 (EDT)
Received: by bkbzs2 with SMTP id zs2so5572664bkb.14
        for <linux-mm@kvack.org>; Sat, 17 Sep 2011 11:34:03 -0700 (PDT)
Date: Sat, 17 Sep 2011 22:33:58 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v2 4/7] per-cgroup tcp buffers control
Message-ID: <20110917183358.GB2783@moon>
References: <1316051175-17780-1-git-send-email-glommer@parallels.com>
 <1316051175-17780-5-git-send-email-glommer@parallels.com>
 <20110917181132.GC1658@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110917181132.GC1658@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org

On Sat, Sep 17, 2011 at 09:11:32PM +0300, Kirill A. Shutemov wrote:
> On Wed, Sep 14, 2011 at 10:46:12PM -0300, Glauber Costa wrote:
> > +int tcp_init_cgroup_fill(struct proto *prot, struct cgroup *cgrp,
> > +			 struct cgroup_subsys *ss)
> > +{
> > +	prot->enter_memory_pressure	= tcp_enter_memory_pressure;
> > +	prot->memory_allocated		= memory_allocated_tcp;
> > +	prot->prot_mem			= tcp_sysctl_mem;
> > +	prot->sockets_allocated		= sockets_allocated_tcp;
> > +	prot->memory_pressure		= memory_pressure_tcp;
> 
> No fancy formatting, please.
> 

What's wrong with having fancy formatting? It's indeed easier to read
when members are assigned this way. It's always up to maintainer to
choose what he prefers, but I see nothing wrong in such style (if only it
doesn't break the style of the whole file).

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
