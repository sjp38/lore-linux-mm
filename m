Received: from talaria.fm.intel.com (talaria.fm.intel.com [10.1.192.39])
	by caduceus.fm.intel.com (8.11.6/8.11.6/d: outer.mc,v 1.51 2002/09/23 20:43:23 dmccart Exp $) with ESMTP id h1Q30N802896
	for <linux-mm@kvack.org>; Wed, 26 Feb 2003 03:00:23 GMT
Received: from fmsmsxvs043.fm.intel.com (fmsmsxvs043.fm.intel.com [132.233.42.129])
	by talaria.fm.intel.com (8.11.6/8.11.6/d: inner.mc,v 1.28 2003/01/13 19:44:39 dmccart Exp $) with SMTP id h1Q38Dr21722
	for <linux-mm@kvack.org>; Wed, 26 Feb 2003 03:08:13 GMT
Message-ID: <A46BBDB345A7D5118EC90002A5072C780A7D57BB@orsmsx116.jf.intel.com>
From: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>
Subject: RE: Silly question: How to map a user space page in kernel space?
Date: Tue, 25 Feb 2003 19:06:34 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "'Martin J. Bligh'" <mbligh@aracnet.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Martin J. Bligh wrote:
>
> > Inaky Perez-Gonzalez wrote:
> >
> > I have a user space page (I know the 'struct page *' and I did a
> > get_page() on it so it doesn't go away to swap) and I need to be able to
> > access it with normal pointers (to do a bunch of atomic operations on
> > it). I cannot use get_user() and friends, just pointers.
> >
> > So, the question is, how can I map it into the kernel space in a
> > portable manner? Am I missing anything very basic here?
> 
> kmap or kmap_atomic

I am trying to use kmap_atomic(), but what is the meaning of the second
argument, km_type? I cannot find it anywhere, or at least the difference
between KM_USER0 and KM_USER1, which I am guessing are the ones I need.

Inaky Perez-Gonzalez--Not speaking for Intel--opinions are my own (and my
fault)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
