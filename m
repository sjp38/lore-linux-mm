Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id CEFE26B0074
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 11:43:28 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 29 Oct 2012 11:43:27 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 60A006E8036
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 11:43:23 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9TFhMbs291378
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 11:43:23 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9TFhLGY016314
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 09:43:22 -0600
Message-ID: <508EA417.1040304@linux.vnet.ibm.com>
Date: Mon, 29 Oct 2012 10:43:19 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 0/3] zram/zsmalloc promotion
References: <1351501009-15111-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1351501009-15111-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Jens Axboe <axboe@kernel.dk>, Dan Magenheimer <dan.magenheimer@oracle.com>, Pekka Enberg <penberg@cs.helsinki.fi>, gaowanlong@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/29/2012 03:56 AM, Minchan Kim wrote:
> This patchset promotes zram/zsmalloc from staging.
> Both are very clean and zram have been used by many embedded product
> for a long time.
> It's time to go out of staging.

Agreed!

> Greg, Jens is already OK that zram is located under driver/blocks/.
> The issue remained is where we put zsmalloc.

Doesn't matter much for me, but seems to be leaning toward /lib,
baring an opinion from Andrew that it go in /mm.  /lib is fine by me.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
