Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1F7896B0169
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 01:50:58 -0400 (EDT)
Date: Mon, 1 Nov 2010 06:40:27 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] cgroup: Avoid a memset by using vzalloc
In-Reply-To: <20101031173336.GA28141@balbir.in.ibm.com>
Message-ID: <alpine.LNX.2.00.1011010639410.31190@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1010302333130.1572@swampdragon.chaosbits.net> <AANLkTi=nMU3ezNFD8LKBhJxr6CmW6-qHY_Mo3HRt6Os0@mail.gmail.com> <20101031173336.GA28141@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sun, 31 Oct 2010, Balbir Singh wrote:

> * MinChan Kim <minchan.kim@gmail.com> [2010-10-31 08:34:01]:
> 
> > On Sun, Oct 31, 2010 at 6:35 AM, Jesper Juhl <jj@chaosbits.net> wrote:
> > > Hi,
> > >
> > > We can avoid doing a memset in swap_cgroup_swapon() by using vzalloc().
> > >
> > >
> > > Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> > Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> > 
> > There are so many placed need vzalloc.
> > Thanks, Jesper.
> 
> Yes, please check memcontrol.c as well
> 
I will shortly, I'm slowly working my way through a mountain of code 
checking for this. I'll get to memcontrol.c

> 
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>  
Thanks.

-- 
Jesper Juhl <jj@chaosbits.net>             http://www.chaosbits.net/
Plain text mails only, please      http://www.expita.com/nomime.html
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
