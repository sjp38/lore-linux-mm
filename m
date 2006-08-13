Date: Sun, 13 Aug 2006 13:52:05 +0400
From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
Message-ID: <20060813095205.GA5458@2ka.mipt.ru>
References: <20060812084713.GA29523@2ka.mipt.ru> <1155374390.13508.15.camel@lappy> <20060812093706.GA13554@2ka.mipt.ru> <20060812.174607.44371641.davem@davemloft.net> <20060813090620.GB14960@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
In-Reply-To: <20060813090620.GB14960@2ka.mipt.ru>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: a.p.zijlstra@chello.nl, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, phillips@google.com
List-ID: <linux-mm.kvack.org>

On Sun, Aug 13, 2006 at 01:06:21PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> On Sat, Aug 12, 2006 at 05:46:07PM -0700, David Miller (davem@davemloft.net) wrote:
> > From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> > Date: Sat, 12 Aug 2006 13:37:06 +0400
> > 
> > > Does it? I though it is possible to only have 64k of working sockets per
> > > device in TCP.
> > 
> > Where does this limit come from?
> > 
> > You think there is something magic about 64K local ports,
> > but if remote IP addresses in the TCP socket IDs are all
> > different, number of possible TCP sockets is only limited
> > by "number of client IPs * 64K" and ram :-)
> 
> I talked about working sockets, but not about how many of them system
> can have at all :)

working -> bound.

-- 
	Evgeniy Polyakov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
