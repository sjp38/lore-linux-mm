Date: Fri, 16 Nov 2001 07:47:46 -0800 (PST)
Message-Id: <20011116.074746.133020969.davem@redhat.com>
Subject: Re: [parisc-linux] Re: parisc scatterlist doesn't want page/offset
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20011116154350.L25491@parcelfarce.linux.theplanet.co.uk>
References: <20011116152601.K25491@parcelfarce.linux.theplanet.co.uk>
	<20011116.073328.129356309.davem@redhat.com>
	<20011116154350.L25491@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: willy@debian.org
Cc: grundler@puffin.external.hp.com, linux-mm@kvack.org, parisc-linux@lists.parisc-linux.org
List-ID: <linux-mm.kvack.org>

   
   grant suggested adding support for it had performance implications,
   so he wasn't willing to let me make that edit.  i'm not sure i entirely
   understand the new scheme either.  the danger of updating code without
   updating its supporting documentation.

If "address" is NULL, use page+offset.  It's pretty simple.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
