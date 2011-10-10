Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 65DEE6B002D
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 15:17:27 -0400 (EDT)
Subject: Re: [PATCH 0/9] skb fragment API: convert network drivers (part V)
From: Ian Campbell <Ian.Campbell@citrix.com>
In-Reply-To: <1318272731.2567.4.camel@edumazet-laptop>
References: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
	 <20111010.142040.2267571270586671416.davem@davemloft.net>
	 <1318272731.2567.4.camel@edumazet-laptop>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 10 Oct 2011 20:17:04 +0100
Message-ID: <1318274224.27397.11.camel@dagon.hellion.org.uk>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, 2011-10-10 at 19:52 +0100, Eric Dumazet wrote:
> Le lundi 10 octobre 2011 a 14:20 -0400, David Miller a ecrit :
> > From: Ian Campbell <Ian.Campbell@citrix.com>
> > Date: Mon, 10 Oct 2011 12:11:16 +0100
> > 
> > > I think "struct subpage" is a generally useful tuple I added to a
> > > central location (mm_types.h) rather than somewhere networking or driver
> > > specific but I can trivially move if preferred.
> > 
> > I'm fine with the patch series, but this generic datastructure
> > addition needs some feedback first.

Sure. Would you take patches 6, 7 & 8 now? They don't rely on the new
struct.

> I was planning to send a patch to abstract frag->size manipulation and
> ease upcoming truesize certification work.
[...]
> Is it OK if I send a single patch right now ?
> 
> I am asking because it might clash a bit with Ian work.

FWIW it's fine with me, there is only the half dozen or so drivers in
this series left to convert and I can rebase pretty easily.

Ian.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
