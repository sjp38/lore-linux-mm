Date: Wed, 16 Aug 2006 23:27:26 +0400
From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH2 1/1] network memory allocator.
Message-ID: <20060816192726.GB19537@2ka.mipt.ru>
References: <20060814110359.GA27704@2ka.mipt.ru> <20060816075137.GA22397@2ka.mipt.ru> <20060816095712.120b3171@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
In-Reply-To: <20060816095712.120b3171@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Hemminger <shemminger@osdl.org>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 16, 2006 at 09:57:12AM -0700, Stephen Hemminger (shemminger@osdl.org) wrote:
> IMHO the network memory allocator is being a little too focused on one problem,
> rather than looking at a general enhancement.
> 
> Have you looked into something like the talloc used by Samba (and others)?
> 	http://talloc.samba.org/
> 	http://samba.org/ftp/unpacked/samba4/source/lib/talloc/talloc_guide.txt
> 
> By having a context, we could do better resource tracking and also cleanup
> would be easier on removal.

Yes, I saw it - it is slow (not that big overhead, but it definitely not
the case where we can slow things down more).
Netwrok tree allocator can be used by other users too without any
problems ,mmu-less systems will greatly benefit from it.
There is nothing which prevent other than network cases, so I see no
problems there.

-- 
	Evgeniy Polyakov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
