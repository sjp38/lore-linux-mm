Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 96E456B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 10:17:17 -0400 (EDT)
Received: from /spool/local
	by e5.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 14 Jun 2012 10:17:16 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 8721D6E806F
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 10:14:24 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5EEENIJ200954
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 10:14:23 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5EEDtu3008115
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 08:13:56 -0600
Message-ID: <4FD9F19E.4000209@linux.vnet.ibm.com>
Date: Thu, 14 Jun 2012 09:13:50 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] staging: zsmalloc: fix uninit'ed variable warning
References: <1339621422-8449-1-git-send-email-sjenning@linux.vnet.ibm.com> <4FD93FE8.1030102@kernel.org>
In-Reply-To: <4FD93FE8.1030102@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 06/13/2012 08:35 PM, Minchan Kim wrote:

> Nice catch!


by Andrew!

> Nitpick:
> I can't see the warning.
> My gcc version is gcc (Ubuntu/Linaro 4.6.3-1ubuntu5) 4.6.3.


I couldn't either but Andrew could and he verified the fix.

Not sure what gcc version he is running.

> Please, Cced linux-mm, too.
> Some guys in mm might have a interest in zsmalloc. :)


Meant to include linux-mm :-/  I'll be sure to include
them in future zsmalloc patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
