Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6995E6B0253
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 18:01:46 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id n128so182849782pfn.3
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 15:01:46 -0800 (PST)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id 2si50532733pfj.77.2016.01.19.15.01.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 15:01:45 -0800 (PST)
Received: by mail-pf0-x234.google.com with SMTP id n128so182849656pfn.3
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 15:01:45 -0800 (PST)
Date: Tue, 19 Jan 2016 15:01:44 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 1/3] oom, sysrq: Skip over oom victims and killed tasks
In-Reply-To: <20160115153721.7d363aef@lxorguk.ukuu.org.uk>
Message-ID: <alpine.DEB.2.10.1601191458100.7346@chino.kir.corp.google.com>
References: <1452632425-20191-1-git-send-email-mhocko@kernel.org> <1452632425-20191-2-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1601121639450.28831@chino.kir.corp.google.com> <20160113093046.GA28942@dhcp22.suse.cz> <alpine.DEB.2.10.1601131633550.3406@chino.kir.corp.google.com>
 <20160114110037.GC29943@dhcp22.suse.cz> <alpine.DEB.2.10.1601141347220.16227@chino.kir.corp.google.com> <20160115101218.GB14112@dhcp22.suse.cz> <20160115153721.7d363aef@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Fri, 15 Jan 2016, One Thousand Gnomes wrote:

> > > I think it's time to kill sysrq+F and I'll send those two patches
> > > unless there is a usecase I'm not aware of.
> > 
> > I have described one in the part you haven't quoted here. Let me repeat:
> > : Your system might be trashing to the point you are not able to log in
> > : and resolve the situation in a reasonable time yet you are still not
> > : OOM. sysrq+f is your only choice then.
> > 
> > Could you clarify why it is better to ditch a potentially usefull
> > emergency tool rather than to make it work reliably and predictably?
> 
> Even if it doesn't work reliably and predictably it is *still* better
> than removing it as it works currently. Today we have "might save you a
> reboot", the removal turns it into "you'll have to reboot". That's a
> regression.
> 

Under what circumstance are you supposing to use sysrq+f in your 
hypothetical?  If you have access to the shell, then you can kill any 
process at random (and you may even be able to make better realtime 
decisions than the oom killer) and it will gain access to memory reserves 
immediately under my proposal when it tries to allocate memory.  The net 
result is that calling the oom killer is no better than you issuing the 
SIGKILL yourself.

This doesn't work if your are supposing to use sysrq+f without the ability 
to get access to the shell.  That's the point, I believe, that Michal has 
raised in this thread.  I'd like to address that issue directly rather 
than requiring human intervention to fix.  If you have deployed a very 
large number of machines to your datacenters, you don't possibly have the 
resources to do this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
