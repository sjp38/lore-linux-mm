Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id CEF716B00B1
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 14:19:53 -0400 (EDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 31 Jul 2012 12:19:52 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id A708719D803E
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 18:19:41 +0000 (WET)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6VIJLoM053136
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 12:19:22 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6VIJGgr001613
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 12:19:21 -0600
Message-ID: <501821A1.3010208@linux.vnet.ibm.com>
Date: Tue, 31 Jul 2012 13:19:13 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] promote zcache from staging
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com> <b95aec06-5a10-4f83-bdfd-e7f6adabd9df@default> <20120727205932.GA12650@localhost.localdomain> <d4656ba5-d6d1-4c36-a6c8-f6ecd193b31d@default> <5016DE4E.5050300@linux.vnet.ibm.com> <f47a6d86-785f-498c-8ee5-0d2df1b2616c@default> <20120731155843.GP4789@phenom.dumpdata.com> <20120731161916.GA4941@kroah.com> <20120731175142.GE29533@phenom.dumpdata.com>
In-Reply-To: <20120731175142.GE29533@phenom.dumpdata.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, devel@driverdev.osuosl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On 07/31/2012 12:51 PM, Konrad Rzeszutek Wilk wrote:
> Would Monday Aug 6th at 1pm EST on irc.freenode.net channel #zcache work
> for people?

I think this is a great idea!

Dan, can you post code as an RFC by tomorrow or Thursday?
We (Rob and I) have the Texas Linux Fest starting Friday.
We need time to review the code prior to chat so that we can
talk about specifics rather than generalities.

If that can be done, then we are available for the chat on
Monday.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
