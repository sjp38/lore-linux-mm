Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 11CE96B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 15:42:43 -0400 (EDT)
Received: by wwi36 with SMTP id 36so7480307wwi.26
        for <linux-mm@kvack.org>; Mon, 10 Oct 2011 12:42:41 -0700 (PDT)
Subject: Re: [PATCH 0/9] skb fragment API: convert network drivers (part V)
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <20111010.151858.301337439177641970.davem@davemloft.net>
References: <20111010.142040.2267571270586671416.davem@davemloft.net>
	 <1318272731.2567.4.camel@edumazet-laptop>
	 <1318274224.27397.11.camel@dagon.hellion.org.uk>
	 <20111010.151858.301337439177641970.davem@davemloft.net>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 10 Oct 2011 21:42:15 +0200
Message-ID: <1318275735.2567.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: Ian.Campbell@citrix.com, netdev@vger.kernel.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org

Le lundi 10 octobre 2011 A  15:18 -0400, David Miller a A(C)crit :
> From: Ian Campbell <Ian.Campbell@citrix.com>
> Date: Mon, 10 Oct 2011 20:17:04 +0100
> 
> > On Mon, 2011-10-10 at 19:52 +0100, Eric Dumazet wrote:
> >> Le lundi 10 octobre 2011 A  14:20 -0400, David Miller a A(C)crit :
> >> > From: Ian Campbell <Ian.Campbell@citrix.com>
> >> > Date: Mon, 10 Oct 2011 12:11:16 +0100
> >> > 
> >> > > I think "struct subpage" is a generally useful tuple I added to a
> >> > > central location (mm_types.h) rather than somewhere networking or driver
> >> > > specific but I can trivially move if preferred.
> >> > 
> >> > I'm fine with the patch series, but this generic datastructure
> >> > addition needs some feedback first.
> > 
> > Sure. Would you take patches 6, 7 & 8 now? They don't rely on the new
> > struct.
> 
> I'll do that right now, thanks Ian.

I'll respin my patch once your tree is pushed.

Thanks


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
