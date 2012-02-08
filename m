Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 2D9CF6B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 18:07:54 -0500 (EST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 8 Feb 2012 16:07:52 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 5DAE41FF0049
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 16:07:17 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q18N7G7Y104720
	for <linux-mm@kvack.org>; Wed, 8 Feb 2012 16:07:16 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q18N7EN9017056
	for <linux-mm@kvack.org>; Wed, 8 Feb 2012 16:07:15 -0700
Message-ID: <4F33001E.50600@linux.vnet.ibm.com>
Date: Wed, 08 Feb 2012 15:07:10 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] staging: zsmalloc: zsmalloc memory allocation library
References: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com> <1326149520-31720-2-git-send-email-sjenning@linux.vnet.ibm.com> <4F21A5AF.6010605@linux.vnet.ibm.com> <4F300D41.5050105@linux.vnet.ibm.com> <4F32A55E.8010401@linux.vnet.ibm.com> <4F32B6A4.8030702@vflare.org> <4F32BEDC.6030502@linux.vnet.ibm.com> <4F32E1D2.4010809@vflare.org> <52f90b19-84b5-4e97-952a-373bdfeaa77d@default>
In-Reply-To: <52f90b19-84b5-4e97-952a-373bdfeaa77d@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg KH <greg@kroah.com>, Brian King <brking@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 02/08/2012 01:39 PM, Dan Magenheimer wrote:
>> > map_vm_area() needs 'struct vm_struct' parameter but for mapping kernel
>> > allocated pages within kernel, what should we pass here?  I think we can
>> > instead use map_kernel_range_noflush() -- surprisingly
>> > unmap_kernel_range_noflush() is exported but this one is not.
> Creating a dependency on a core kernel change (even just an EXPORT_SYMBOL)
> is probably not a good idea.  Unless Dave vehemently objects, I'd suggest
> implementing it both ways, leaving the method that relies on the
> kernel change ifdef'd out, and add this to "the list of things that
> need to be done before zcache can be promoted out of staging".

Seems like a sane approach to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
