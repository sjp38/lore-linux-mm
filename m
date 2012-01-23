Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 0AE5F6B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 09:28:48 -0500 (EST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 23 Jan 2012 07:28:47 -0700
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id CB3E33E40059
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 07:28:44 -0700 (MST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0NERMT1197016
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 09:27:22 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0NERI64011083
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 09:27:18 -0500
Message-ID: <4F1D6E44.6070509@linux.vnet.ibm.com>
Date: Mon, 23 Jan 2012 08:27:16 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] staging: zsmalloc: memory allocator for compressed
 pages
References: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com> <20120120140344.2fb399e4.akpm@linux-foundation.org>
In-Reply-To: <20120120140344.2fb399e4.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Dan Magenheimer <dan.magenheimer@oracle.com>, Brian King <brking@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Wilk <konrad.wilk@oracle.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Hey Andrew,

Thanks for the feedback.

On 01/20/2012 04:03 PM, Andrew Morton wrote:
> On Mon,  9 Jan 2012 16:51:55 -0600
> Seth Jennings <sjenning@linux.vnet.ibm.com> wrote:
> 
> The changelog doesn't really describe why the code was written and
> provides no reason for anyone to merge it. <snip>  This is the most important
> part of the patch description and you completely omitted it!

Sorry about that.  The purpose is to replace the xvmalloc allocator
that both zcache and zram use that suffers from the high fragmentation
described.  I 'll be sure to add this to the cover letter.

I was thinking it would go to lib after staging.

Thanks,
--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
