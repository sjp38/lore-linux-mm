Date: Fri, 16 Nov 2001 15:04:54 +0000
From: Matthew Wilcox <willy@debian.org>
Subject: Re: [parisc-linux] Re: parisc scatterlist doesn't want page/offset
Message-ID: <20011116150454.J25491@parcelfarce.linux.theplanet.co.uk>
References: <200111160730.AAA18774@puffin.external.hp.com> <20011116.065243.134136673.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20011116.065243.134136673.davem@redhat.com>; from davem@redhat.com on Fri, Nov 16, 2001 at 06:52:43AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: grundler@puffin.external.hp.com, linux-mm@kvack.org, parisc-linux@lists.parisc-linux.org
List-ID: <linux-mm.kvack.org>

On Fri, Nov 16, 2001 at 06:52:43AM -0800, David S. Miller wrote:
> 
> No, you must have page+offset because in the future the
> "address" field of scatterlist is going to disappear
> and _ONLY_ page+offset will be used.

but _WHY_ in 2.4?  this is ridiculous for something which is alleged to
be a stable kernel.

-- 
Revolutions do not require corporate support.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
