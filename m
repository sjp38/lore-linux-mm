Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id F248C6B002C
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 09:56:15 -0500 (EST)
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 9 Feb 2012 09:56:14 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id DCB696E8049
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 09:55:49 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q19Etn1w252118
	for <linux-mm@kvack.org>; Thu, 9 Feb 2012 09:55:49 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q19EtnT8011036
	for <linux-mm@kvack.org>; Thu, 9 Feb 2012 12:55:49 -0200
Message-ID: <4F33DE6F.80308@linux.vnet.ibm.com>
Date: Thu, 09 Feb 2012 08:55:43 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] staging: zcache: replace xvmalloc with zsmalloc
References: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com> <1326149520-31720-4-git-send-email-sjenning@linux.vnet.ibm.com> <20120209011326.GA2225@kroah.com>
In-Reply-To: <20120209011326.GA2225@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Brian King <brking@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On 02/08/2012 07:13 PM, Greg KH wrote:
> On Mon, Jan 09, 2012 at 04:51:58PM -0600, Seth Jennings wrote:
>> Replaces xvmalloc with zsmalloc as the persistent memory allocator
>> for zcache
>>
>> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> 
> This patch no longer applies :(

Looks like my "staging: zcache: fix serialization bug in zv stats"
patch didn't go in first.  There is an order dependency there.
https://lkml.org/lkml/2012/1/9/403

Let me know if there is still an issue after applying that patch.

Thanks!
--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
