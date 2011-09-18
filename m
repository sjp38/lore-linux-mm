Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9440C9000BD
	for <linux-mm@kvack.org>; Sun, 18 Sep 2011 14:58:08 -0400 (EDT)
Date: Sun, 18 Sep 2011 21:58:06 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 4/7] per-cgroup tcp buffers control
Message-ID: <20110918185806.GA28057@shutemov.name>
References: <1316051175-17780-1-git-send-email-glommer@parallels.com>
 <1316051175-17780-5-git-send-email-glommer@parallels.com>
 <20110917181132.GC1658@shutemov.name>
 <20110917183358.GB2783@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110917183358.GB2783@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org

On Sat, Sep 17, 2011 at 10:33:58PM +0400, Cyrill Gorcunov wrote:
> On Sat, Sep 17, 2011 at 09:11:32PM +0300, Kirill A. Shutemov wrote:
> > On Wed, Sep 14, 2011 at 10:46:12PM -0300, Glauber Costa wrote:
> > > +int tcp_init_cgroup_fill(struct proto *prot, struct cgroup *cgrp,
> > > +			 struct cgroup_subsys *ss)
> > > +{
> > > +	prot->enter_memory_pressure	= tcp_enter_memory_pressure;
> > > +	prot->memory_allocated		= memory_allocated_tcp;
> > > +	prot->prot_mem			= tcp_sysctl_mem;
> > > +	prot->sockets_allocated		= sockets_allocated_tcp;
> > > +	prot->memory_pressure		= memory_pressure_tcp;
> > 
> > No fancy formatting, please.
> > 
> 
> What's wrong with having fancy formatting? It's indeed easier to read
> when members are assigned this way. It's always up to maintainer to
> choose what he prefers, but I see nothing wrong in such style (if only it
> doesn't break the style of the whole file).

You have to remove this indenting if you'll reorganize code (e.g. move
part under if(...)).
IMO, it reduces code maintainability.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
