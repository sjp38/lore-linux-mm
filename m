Received: from petasus.hd.intel.com (petasus.hd.intel.com [10.127.45.3])
	by hermes.hd.intel.com (8.11.6/8.11.6/d: outer.mc,v 1.51 2002/09/23 20:43:23 dmccart Exp $) with ESMTP id h1LMlYY10047
	for <linux-mm@kvack.org>; Fri, 21 Feb 2003 22:47:34 GMT
Received: from orsmsxvs040.jf.intel.com (orsmsxvs040.jf.intel.com [192.168.65.206])
	by petasus.hd.intel.com (8.11.6/8.11.6/d: inner.mc,v 1.28 2003/01/13 19:44:39 dmccart Exp $) with SMTP id h1LMk0J19327
	for <linux-mm@kvack.org>; Fri, 21 Feb 2003 22:46:01 GMT
Message-ID: <A46BBDB345A7D5118EC90002A5072C780A7D51C6@orsmsx116.jf.intel.com>
From: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>
Subject: RE: Silly question: How to map a user space page in kernel space?
Date: Fri, 21 Feb 2003 14:49:23 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "'Martin J. Bligh'" <mbligh@aracnet.com>, "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Martin J. Bligh wrote:
>
> > So, the question is, how can I map it into the kernel space in a
> portable
> > manner? Am I missing anything very basic here?
> 
> kmap or kmap_atomic

Thanks Martin, you are the man :)

Inaky Perez-Gonzalez --- Not speaking for Intel -- all opinions are my own
(and my fault)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
