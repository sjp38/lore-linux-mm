Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 40AC56B002C
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 09:37:05 -0500 (EST)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 9 Feb 2012 07:37:03 -0700
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 6E5D4C9005A
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 09:36:47 -0500 (EST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q19EakET298062
	for <linux-mm@kvack.org>; Thu, 9 Feb 2012 09:36:46 -0500
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q19EaiQE017789
	for <linux-mm@kvack.org>; Thu, 9 Feb 2012 07:36:44 -0700
Message-ID: <4F33D9EC.9050900@linux.vnet.ibm.com>
Date: Thu, 09 Feb 2012 08:36:28 -0600
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

Let me check it out, I'll get back to you shortly.

Thanks for merging everything else!

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
