Date: Fri, 16 Nov 2001 07:33:28 -0800 (PST)
Message-Id: <20011116.073328.129356309.davem@redhat.com>
Subject: Re: [parisc-linux] Re: parisc scatterlist doesn't want page/offset
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20011116152601.K25491@parcelfarce.linux.theplanet.co.uk>
References: <20011116150454.J25491@parcelfarce.linux.theplanet.co.uk>
	<20011116.071751.12999342.davem@redhat.com>
	<20011116152601.K25491@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: willy@debian.org
Cc: grundler@puffin.external.hp.com, linux-mm@kvack.org, parisc-linux@lists.parisc-linux.org
List-ID: <linux-mm.kvack.org>

   
   so when jens' code is merged back into 2.4 we won't have to make any
   changes to the arch dependent code?
   
Part of the criteria to whether we merge back Jens' code is
if the ports, given reasonable notice (ie. take this as your notice)
have added in the support for page+offset pairs to their pci_map_sg
code.

I suggest you do this now, it is totally painless.  I would almost
classify it as a mindless edit.

Franks a lot,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
