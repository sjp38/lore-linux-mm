Received: from petasus.fm.intel.com (petasus.fm.intel.com [10.1.192.37])
	by caduceus.fm.intel.com (8.11.6/8.11.6/d: outer.mc,v 1.51 2002/09/23 20:43:23 dmccart Exp $) with ESMTP id h1LM0Fl21922
	for <linux-mm@kvack.org>; Fri, 21 Feb 2003 22:00:15 GMT
Received: from fmsmsxvs041.fm.intel.com (fmsmsxvs041.fm.intel.com [132.233.42.126])
	by petasus.fm.intel.com (8.11.6/8.11.6/d: inner.mc,v 1.28 2003/01/13 19:44:39 dmccart Exp $) with SMTP id h1LM13H29725
	for <linux-mm@kvack.org>; Fri, 21 Feb 2003 22:01:03 GMT
Received: from fmsmsx28.fm.intel.com ([132.233.42.28])
 by fmsmsxvs041.fm.intel.com (NAVGW 2.5.2.11) with SMTP id M2003022114041419242
 for <linux-mm@kvack.org>; Fri, 21 Feb 2003 14:04:14 -0800
Message-ID: <A46BBDB345A7D5118EC90002A5072C780A7D5194@orsmsx116.jf.intel.com>
From: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>
Subject: Silly question: How to map a user space page in kernel space?
Date: Fri, 21 Feb 2003 14:06:21 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-1"
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi All

Got a naive question I cannot find the answer for: 

I have a user space page (I know the 'struct page *' and I did a get_page()
on it so it doesn't go away to swap) and I need to be able to access it with
normal pointers (to do a bunch of atomic operations on it). I cannot use
get_user() and friends, just pointers.

So, the question is, how can I map it into the kernel space in a portable
manner? Am I missing anything very basic here?

Thanks in advance :)

PS: I suspect remap_page_range() is going to be involved, but I cannot see
how.

Inaky Perez-Gonzalez --- Not speaking for Intel -- all opinions are my own
(and my fault)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
