Received: from cs.amherst.edu
 ("port 1422"@host-17.subnet-238.amherst.edu [148.85.238.17])
 by amherst.edu (PMDF V6.0-24 #39159)
 with ESMTP id <01JRVDKN09JO8WXBXZ@amherst.edu> for linux-mm@kvack.org; Mon,
 17 Jul 2000 10:58:19 -0400 (EDT)
Date: Mon, 17 Jul 2000 10:55:52 -0400
From: "Scott F. Kaplan" <sfkaplan@cs.amherst.edu>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
Message-id: <39731E78.C152D049@cs.amherst.edu>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
References: <200007171446.KAA07554@devserv.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:
> Modern OS designers are consistently seeing LFU work better. In our case this
> is partly theory in the FreeBSD case its proven by trying it.

Have any of the FreeBSD people compiled some results to this effect? 
I'd be interested to see under what circumstances LFU works better, and
just what approximations of both LRU and LFU are being used.  There
could be something interesting in such results, as years of other
experiments have shown otherwise.

Scott Kaplan
sfkaplan@cs.amherst.edu
http://www.cs.amherst.edu/~sfkaplan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
