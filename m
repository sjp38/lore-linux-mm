Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 54F296B004D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 18:11:05 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 23 Jul 2012 16:11:04 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 5504219D8036
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 22:10:57 +0000 (WET)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6NMAggO090436
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 16:10:42 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6NMAfs7022121
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 16:10:42 -0600
Message-ID: <500DCBDF.5090800@linux.vnet.ibm.com>
Date: Mon, 23 Jul 2012 17:10:39 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] zsmalloc: s/firstpage/page in new copy map funcs
References: <1342630556-28686-1-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1342630556-28686-1-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Greg,

I know it's the first Monday after a kernel release and
things are crazy for you.  I was hoping to get this zsmalloc
stuff in before the merge window hit so I wouldn't have to
bother you :-/  But, alas, it didn't happen that way.

Minchan acked these yesterday.  When you get a chance, could
you pull these 3 patches?  I'm wanting to send out a
promotion patch for zsmalloc and zcache based on these.

Thanks Greg!

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
