Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id QAA08643
	for <linux-mm@kvack.org>; Sat, 21 Sep 2002 16:27:05 -0700 (PDT)
Message-ID: <3D8D0046.EF119E03@digeo.com>
Date: Sat, 21 Sep 2002 16:27:02 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: overcommit stuff
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Alan,

running 10,000 tiobench threads I'm showing 23 gigs of
`Commited_AS'.  Is this right?  Those pages are shared,
and if they're not PROT_WRITEable then there's no way in
which they can become unshared?   Seems to be excessively
pessimistic?

Or is 2.5 not up to date?

Thanks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
