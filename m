Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 606C96B00EF
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 15:09:50 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 21 Jun 2012 13:09:46 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 907D419D8B8A
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 18:51:38 +0000 (WET)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5LIpZYG205802
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 12:51:37 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5LIqW5f011731
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 12:52:32 -0600
Message-ID: <4FE36D32.3030408@linux.vnet.ibm.com>
Date: Thu, 21 Jun 2012 13:51:30 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/10] zcache: fix preemptable memory allocation in atomic
 context
References: <4FE0392E.3090300@linux.vnet.ibm.com>
In-Reply-To: <4FE0392E.3090300@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

I just noticed you sent this patchset to Andrew, but the
staging tree is maintained by Greg.  You're going to want to
send these patches to him.

Greg Kroah-Hartman <gregkh@linuxfoundation.org>

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
