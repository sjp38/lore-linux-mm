Received: from talaria.fm.intel.com (talaria.fm.intel.com [10.1.192.39])
	by caduceus.fm.intel.com (8.11.6/8.11.6/d: outer.mc,v 1.51 2002/09/23 20:43:23 dmccart Exp $) with ESMTP id h1QIpto13902
	for <linux-mm@kvack.org>; Wed, 26 Feb 2003 18:51:57 GMT
Received: from fmsmsxvs042.fm.intel.com (fmsmsxvs042.fm.intel.com [132.233.42.128])
	by talaria.fm.intel.com (8.11.6/8.11.6/d: inner.mc,v 1.28 2003/01/13 19:44:39 dmccart Exp $) with SMTP id h1QIxYc17717
	for <linux-mm@kvack.org>; Wed, 26 Feb 2003 18:59:43 GMT
Message-ID: <A46BBDB345A7D5118EC90002A5072C780A7D590A@orsmsx116.jf.intel.com>
From: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>
Subject: RE: Silly question: How to map a user space page in kernel space?
Date: Wed, 26 Feb 2003 10:57:51 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Mel Gorman' <mel@csn.ul.ie>
Cc: "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> From: Mel Gorman [mailto:mel@csn.ul.ie]
>
> > I think I still don't really understand what's up with the KM_ flags :]
> >
> 
> I'm doing a bit of VM documentation work. I haven't released an update in
> a while but I have a chapter on high memory management chapter in my
> working version. It covers the various kmap functions, atomic mapping and
> an explanation of KM_ flags. I uploaded just that chapter to
> http://www.csn.ul.ie/~mel/projects/vm/tmp/ in both PDF (recommended one to
> view) and plain text format if you want to take a look. It's against
> 2.4.20, but I believe it is of relevance to 2.5.x as well
> 
> Hope that helps

Sure it will; your doc was the first pointer I went too [btw,
congratulations and thank you, it is really helpful], but, yep, it wasn't
there. Checking out the new version right now.

Inaky Perez-Gonzalez -- Not speaking for Intel -- all opinions are my own
(and my fault)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
