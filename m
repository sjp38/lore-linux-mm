Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 832048D0001
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 10:38:29 -0400 (EDT)
Date: Wed, 3 Nov 2010 09:38:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] cgroup: Avoid a memset by using vzalloc
In-Reply-To: <alpine.LNX.2.00.1011010639410.31190@swampdragon.chaosbits.net>
Message-ID: <alpine.DEB.2.00.1011030937580.10599@router.home>
References: <alpine.LNX.2.00.1010302333130.1572@swampdragon.chaosbits.net> <AANLkTi=nMU3ezNFD8LKBhJxr6CmW6-qHY_Mo3HRt6Os0@mail.gmail.com> <20101031173336.GA28141@balbir.in.ibm.com> <alpine.LNX.2.00.1011010639410.31190@swampdragon.chaosbits.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jesper Juhl <jj@chaosbits.net>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Minchan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Nov 2010, Jesper Juhl wrote:

> On Sun, 31 Oct 2010, Balbir Singh wrote:

> > > There are so many placed need vzalloc.
> > > Thanks, Jesper.


Could we avoid this painful exercise with a "semantic patch"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
