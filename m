Date: Fri, 16 Nov 2001 15:43:50 +0000
From: Matthew Wilcox <willy@debian.org>
Subject: Re: [parisc-linux] Re: parisc scatterlist doesn't want page/offset
Message-ID: <20011116154350.L25491@parcelfarce.linux.theplanet.co.uk>
References: <20011116150454.J25491@parcelfarce.linux.theplanet.co.uk> <20011116.071751.12999342.davem@redhat.com> <20011116152601.K25491@parcelfarce.linux.theplanet.co.uk> <20011116.073328.129356309.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20011116.073328.129356309.davem@redhat.com>; from davem@redhat.com on Fri, Nov 16, 2001 at 07:33:28AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: willy@debian.org, grundler@puffin.external.hp.com, linux-mm@kvack.org, parisc-linux@lists.parisc-linux.org
List-ID: <linux-mm.kvack.org>

On Fri, Nov 16, 2001 at 07:33:28AM -0800, David S. Miller wrote:
>    From: Matthew Wilcox <willy@debian.org>
>    Date: Fri, 16 Nov 2001 15:26:01 +0000
>    
>    so when jens' code is merged back into 2.4 we won't have to make any
>    changes to the arch dependent code?
>    
> Part of the criteria to whether we merge back Jens' code is
> if the ports, given reasonable notice (ie. take this as your notice)
> have added in the support for page+offset pairs to their pci_map_sg
> code.
> 
> I suggest you do this now, it is totally painless.  I would almost
> classify it as a mindless edit.

grant suggested adding support for it had performance implications,
so he wasn't willing to let me make that edit.  i'm not sure i entirely
understand the new scheme either.  the danger of updating code without
updating its supporting documentation.

-- 
Revolutions do not require corporate support.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
