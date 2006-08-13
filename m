Message-ID: <44DF888F.1010601@google.com>
Date: Sun, 13 Aug 2006 13:16:15 -0700
From: Daniel Phillips <phillips@google.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
References: <1155127040.12225.25.camel@twins>	 <20060809130752.GA17953@2ka.mipt.ru> <1155130353.12225.53.camel@twins>	 <20060809.165431.118952392.davem@davemloft.net> <1155189988.12225.100.camel@twins>
In-Reply-To: <1155189988.12225.100.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: David Miller <davem@davemloft.net>, johnpol@2ka.mipt.ru, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> On Wed, 2006-08-09 at 16:54 -0700, David Miller wrote:
>>People are doing I/O over IP exactly for it's ubiquity and
>>flexibility.  It seems a major limitation of the design if you cancel
>>out major components of this flexibility.
> 
> We're not, that was a bit of my own frustration leaking out; I think 
> this whole push to IP based storage is a bit silly. I'm just not going 
> to help the admin who's server just hangs because his VPN key expired.
>
> Running critical resources remotely like this is tricky, and every 
> hop/layer you put in between increases the risk of something going bad.
> The only setup I think even remotely sane is a dedicated network in the
> very same room - not unlike FC but cheaper (which I think is the whole
> push behind this, eth is cheap)

Indeed.  The rest of the corner cases like netfilter, layered protocol and
so on need to be handled, however they do not need to be handled right now
in order to make remote storage on a lan work properly.  The sane thing for
the immediate future is to flag each socket as safe for remote block IO or
not, then gradually widen the scope of what is safe.  We need to set up an
opt in strategy for network block IO that views such network subsystems as
ipfilter as not safe by default, until somebody puts in the work to make
them safe.

But really, if you expect to run reliable block IO to Zanzibar over an ssh
tunnel through a firewall, then you might also consider taking up bungie
jumping with the cord tied to your neck.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
