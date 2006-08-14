Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20060814051323.GA1335@2ka.mipt.ru>
References: <1155127040.12225.25.camel@twins>
	 <20060809130752.GA17953@2ka.mipt.ru> <1155130353.12225.53.camel@twins>
	 <20060809.165431.118952392.davem@davemloft.net>
	 <1155189988.12225.100.camel@twins> <44DF888F.1010601@google.com>
	 <20060814051323.GA1335@2ka.mipt.ru>
Content-Type: text/plain
Date: Mon, 14 Aug 2006 08:45:43 +0200
Message-Id: <1155537943.5696.118.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Cc: Daniel Phillips <phillips@google.com>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2006-08-14 at 09:13 +0400, Evgeniy Polyakov wrote:
> On Sun, Aug 13, 2006 at 01:16:15PM -0700, Daniel Phillips (phillips@google.com) wrote:
> > Indeed.  The rest of the corner cases like netfilter, layered protocol and
> > so on need to be handled, however they do not need to be handled right now
> > in order to make remote storage on a lan work properly.  The sane thing for
> > the immediate future is to flag each socket as safe for remote block IO or
> > not, then gradually widen the scope of what is safe.  We need to set up an
> > opt in strategy for network block IO that views such network subsystems as
> > ipfilter as not safe by default, until somebody puts in the work to make
> > them safe.
> 
> Just for clarification - it will be completely impossible to login using 
> openssh or some other priveledge separation protocol to the machine due
> to the nature of unix sockets. So you will be unable to manage your
> storage system just because it is in OOM - it is not what is expected
> from reliable system.
> 
> > But really, if you expect to run reliable block IO to Zanzibar over an ssh
> > tunnel through a firewall, then you might also consider taking up bungie
> > jumping with the cord tied to your neck.
> 
> Just pure openssh for control connection (admin should be able to
> login).

These periods of degenerated functionality should be short and
infrequent albeit critical for machine recovery. Would you rather have a
slower ssh login (the machine will recover) or drive/fly to Zanzibar to
physically reboot the machine?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
