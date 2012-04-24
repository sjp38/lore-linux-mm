Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id BFB596B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 09:30:54 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 24 Apr 2012 09:30:53 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id AE4346E804C
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 09:30:38 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3ODUYeN062936
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 09:30:34 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3ODUWWb007055
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 07:30:32 -0600
Message-ID: <4F96AAF4.2000402@linux.vnet.ibm.com>
Date: Tue, 24 Apr 2012 08:30:28 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] drivers: staging: zcache: fix Kconfig crypto dependency
References: <1335231230-29344-1-git-send-email-sjenning@linux.vnet.ibm.com> <20120424022702.GA6573@kroah.com>
In-Reply-To: <20120424022702.GA6573@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Autif Khan <autif.mlist@gmail.com>

On 04/23/2012 09:27 PM, Greg Kroah-Hartman wrote:
> Ok, this fixes one of the build problems reported, what about the other
> one?

Both problems that I heard about were caused by same issue;
the issue fixed in this patch.

ZSMALLOC=m was only allowed because CRYPTO=m was allowed.
This patch requires CRYPTO=y, which also requires ZSMALLOC=y
when ZCACHE=y.

https://lkml.org/lkml/2012/4/19/588

https://lkml.org/lkml/2012/4/23/481

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
