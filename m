Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6996B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 15:19:08 -0400 (EDT)
Date: Mon, 10 Oct 2011 15:18:58 -0400 (EDT)
Message-Id: <20111010.151858.301337439177641970.davem@davemloft.net>
Subject: Re: [PATCH 0/9] skb fragment API: convert network drivers (part V)
From: David Miller <davem@davemloft.net>
In-Reply-To: <1318274224.27397.11.camel@dagon.hellion.org.uk>
References: <20111010.142040.2267571270586671416.davem@davemloft.net>
	<1318272731.2567.4.camel@edumazet-laptop>
	<1318274224.27397.11.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian.Campbell@citrix.com
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Mon, 10 Oct 2011 20:17:04 +0100

> On Mon, 2011-10-10 at 19:52 +0100, Eric Dumazet wrote:
>> Le lundi 10 octobre 2011 =E0 14:20 -0400, David Miller a =E9crit :
>> > From: Ian Campbell <Ian.Campbell@citrix.com>
>> > Date: Mon, 10 Oct 2011 12:11:16 +0100
>> > =

>> > > I think "struct subpage" is a generally useful tuple I added to =
a
>> > > central location (mm_types.h) rather than somewhere networking o=
r driver
>> > > specific but I can trivially move if preferred.
>> > =

>> > I'm fine with the patch series, but this generic datastructure
>> > addition needs some feedback first.
> =

> Sure. Would you take patches 6, 7 & 8 now? They don't rely on the new=

> struct.

I'll do that right now, thanks Ian.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
