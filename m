Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id C716F828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 10:37:40 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id f206so27826456wmf.0
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 07:37:40 -0800 (PST)
Received: from lxorguk.ukuu.org.uk (lxorguk.ukuu.org.uk. [81.2.110.251])
        by mx.google.com with ESMTPS id rx8si18030860wjb.204.2016.01.15.07.37.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jan 2016 07:37:39 -0800 (PST)
Date: Fri, 15 Jan 2016 15:37:21 +0000
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [RFC 1/3] oom, sysrq: Skip over oom victims and killed tasks
Message-ID: <20160115153721.7d363aef@lxorguk.ukuu.org.uk>
In-Reply-To: <20160115101218.GB14112@dhcp22.suse.cz>
References: <1452632425-20191-1-git-send-email-mhocko@kernel.org>
	<1452632425-20191-2-git-send-email-mhocko@kernel.org>
	<alpine.DEB.2.10.1601121639450.28831@chino.kir.corp.google.com>
	<20160113093046.GA28942@dhcp22.suse.cz>
	<alpine.DEB.2.10.1601131633550.3406@chino.kir.corp.google.com>
	<20160114110037.GC29943@dhcp22.suse.cz>
	<alpine.DEB.2.10.1601141347220.16227@chino.kir.corp.google.com>
	<20160115101218.GB14112@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Fri, 15 Jan 2016 11:12:18 +0100
Michal Hocko <mhocko@kernel.org> wrote:

> On Thu 14-01-16 13:51:16, David Rientjes wrote:
> > I think it's time to kill sysrq+F and I'll send those two patches
> > unless there is a usecase I'm not aware of.
> 
> I have described one in the part you haven't quoted here. Let me repeat:
> : Your system might be trashing to the point you are not able to log in
> : and resolve the situation in a reasonable time yet you are still not
> : OOM. sysrq+f is your only choice then.
> 
> Could you clarify why it is better to ditch a potentially usefull
> emergency tool rather than to make it work reliably and predictably?

Even if it doesn't work reliably and predictably it is *still* better
than removing it as it works currently. Today we have "might save you a
reboot", the removal turns it into "you'll have to reboot". That's a
regression.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
