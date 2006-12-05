Received: from ms-mss-01 (ms-mss-01-smtp-b.texas.rr.com [10.93.38.16])
	by ms-smtp-03.texas.rr.com (8.13.6/8.13.6) with ESMTP id kB5HfPSR029770
	for <linux-mm@kvack.org>; Tue, 5 Dec 2006 11:41:25 -0600 (CST)
Received: from texas.rr.com (localhost [127.0.0.1]) by ms-mss-01.texas.rr.com
 (iPlanet Messaging Server 5.2 HotFix 2.10 (built Dec 26 2005))
 with ESMTP id <0J9T00KCJAH1UD@ms-mss-01.texas.rr.com> for linux-mm@kvack.org;
 Tue, 05 Dec 2006 11:41:25 -0600 (CST)
Date: Tue, 05 Dec 2006 11:41:25 -0600
From: aucoin@houston.rr.com
Subject: Re: la la la la ... swappiness
In-reply-to: <20061205085914.b8f7f48d.akpm@osdl.org>
Message-id: <f353cb6c194d4.194d4f353cb6c@texas.rr.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: en
Content-transfer-encoding: 7BIT
Content-disposition: inline
References: <200612050641.kB56f7wY018196@ms-smtp-06.texas.rr.com>
 <Pine.LNX.4.64.0612050754020.3542@woody.osdl.org>
 <20061205085914.b8f7f48d.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
From: Andrew Morton <akpm@osdl.org>
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Aucoin <Aucoin@houston.rr.com>, 'Nick Piggin' <nickpiggin@yahoo.com.au>, 'Tim Schmielau' <tim@physik3.uni-rostock.de>, clameter@sgi.com, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Yes, those pages should be on the LRU.  I suspect they never got 

Oops, details, details.

These are huge pages .... apologies for leaving that out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
