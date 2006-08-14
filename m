Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20060814082555.GA27999@2ka.mipt.ru>
References: <20060813.165540.56347790.davem@davemloft.net>
	 <44DFD262.5060106@google.com> <20060813185309.928472f9.akpm@osdl.org>
	 <1155530453.5696.98.camel@twins> <20060813215853.0ed0e973.akpm@osdl.org>
	 <1155531835.5696.103.camel@twins> <20060813222208.7e8583ac.akpm@osdl.org>
	 <1155537940.5696.117.camel@twins> <20060814000736.80e652bb.akpm@osdl.org>
	 <1155543352.5696.137.camel@twins>  <20060814082555.GA27999@2ka.mipt.ru>
Content-Type: text/plain
Date: Mon, 14 Aug 2006 10:35:40 +0200
Message-Id: <1155544540.5696.144.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Cc: Andrew Morton <akpm@osdl.org>, Daniel Phillips <phillips@google.com>, David Miller <davem@davemloft.net>, riel@redhat.com, tgraf@suug.ch, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Mike Christie <michaelc@cs.wisc.edu>
List-ID: <linux-mm.kvack.org>

On Mon, 2006-08-14 at 12:25 +0400, Evgeniy Polyakov wrote:
> On Mon, Aug 14, 2006 at 10:15:52AM +0200, Peter Zijlstra (a.p.zijlstra@chello.nl) wrote:
> > > If this refers to the socket buffers, they're mostly allocated with
> > > at least __GFP_WAIT, aren't they?
> > 
> > Wherever it is that packets go if the local end is tied up and cannot
> > accept them instantly. The simple but prob wrong calculation I made for
> > evgeniy is: suppose we have 64k sockets, each socket can buffer up to
> > 128 packets, and each packet can be up to 16k (roundup for jumboframes)
> > large, that makes for 128G of memory. This calculation is wrong on
> > several points (we can have >64k sockets, and I have no idea on the 128)
> > but the order of things doesn't get better.
> 
> TCP memory is limited for all sockets - it is tcp_*mem parameters.
> tcp_mem max on my amd64 with 1gb of ram is 768 kb for _all_ sockets.

Yes, I've said as much a few emails back, but that does not make the
theoretical limit any lower.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
