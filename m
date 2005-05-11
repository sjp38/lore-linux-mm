Date: Wed, 11 May 2005 14:59:33 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc3 1/8] mm: manual page migration-rc2 -- xfs-extended-attributes-rc2.patch
Message-ID: <20050511125932.GW25612@wotan.suse.de>
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com> <20050511043802.10876.60521.51027@jackhammer.engr.sgi.com> <20050511071538.GA23090@infradead.org> <4281F650.2020807@engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4281F650.2020807@engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@engr.sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

> But, we do such things by consensus and I am willing to try to implement
> whatever convention we all agree on.  I would like to have an agreement
> from all parties before I proceed with an alternative implementation.
> I will pursue the ld.so changes with the glibc-developers and see what
> the reaction is.


I think Christoph's reaction mostly comes from trying to do this
in file system specific code. Rather it should be some independent
piece of code that just uses the EA interfaces offered by the FS
to do this.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
