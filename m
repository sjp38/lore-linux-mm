Received: from SMTP (orsmsxvs01-1.jf.intel.com [192.168.65.200])
	by ganymede.or.intel.com (8.9.1a+p1/8.9.1/d: relay.m4,v 1.22 2000/04/06 17:58:51 dmccart Exp $) with SMTP id PAA22294
	for <linux-mm@kvack.org>; Wed, 12 Apr 2000 15:13:58 -0700 (PDT)
Message-ID: <A63AFB20111ED311AC5500A0C96B7BF5661F5A@orsmsx36.jf.intel.com>
From: "Chu, Hao-Hua" <hao-hua.chu@intel.com>
Subject: questions
Date: Wed, 12 Apr 2000 15:13:55 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Here are my questions ....
1. How does the readahead work in page cache?  (file->raend, ralen, ramax,
rawin)
2. What kind of pages are in the lru_cache?  (via lru_cache_add())

Thanks.

Hao   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
