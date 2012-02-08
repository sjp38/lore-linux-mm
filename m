Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 1D7B36B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 12:23:06 -0500 (EST)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 8 Feb 2012 10:23:03 -0700
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 18354C9005E
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 12:22:13 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q18HMC1P2764958
	for <linux-mm@kvack.org>; Wed, 8 Feb 2012 12:22:12 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q18HLmXZ009010
	for <linux-mm@kvack.org>; Wed, 8 Feb 2012 10:21:49 -0700
Message-ID: <4F32AF27.8050401@linux.vnet.ibm.com>
Date: Wed, 08 Feb 2012 09:21:43 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] staging: zsmalloc: zsmalloc memory allocation library
References: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com> <1326149520-31720-2-git-send-email-sjenning@linux.vnet.ibm.com> <4F21A5AF.6010605@linux.vnet.ibm.com> <4F300D41.5050105@linux.vnet.ibm.com> <4F32A55E.8010401@linux.vnet.ibm.com> <409797c4-a6e7-493d-9681-4166a9473ab8@default>
In-Reply-To: <409797c4-a6e7-493d-9681-4166a9473ab8@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Brian King <brking@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org

On 02/08/2012 09:15 AM, Dan Magenheimer wrote:
> The zsmalloc allocator can grab
> any random* page "A" with X unused bytes at the END of the page,
> and any random page "B" with Y unused bytes at the BEGINNING of the page
> and "coalesce" them to store any byte sequence with a length** Z
> not exceeding X+Y.  Presumably this markedly increases
> the density of compressed-pages-stored-per-physical-page***.

Ahh, I did miss that.  I assumed it was simply trying to tie two order-0
pages together.  I _guess_ the vmap() comment stands, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
