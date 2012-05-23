Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id A1F916B0083
	for <linux-mm@kvack.org>; Wed, 23 May 2012 16:10:11 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 23 May 2012 14:10:10 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id E685CC40002
	for <linux-mm@kvack.org>; Wed, 23 May 2012 14:09:56 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4NK9iFm036080
	for <linux-mm@kvack.org>; Wed, 23 May 2012 14:09:47 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4NK9hok030490
	for <linux-mm@kvack.org>; Wed, 23 May 2012 14:09:44 -0600
Message-ID: <4FBD4402.7060509@linux.vnet.ibm.com>
Date: Wed, 23 May 2012 15:09:38 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2 v2] zram: clean up handle
References: <1337737402-16543-1-git-send-email-minchan@kernel.org> <1337737402-16543-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1337737402-16543-2-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>

On 05/22/2012 08:43 PM, Minchan Kim wrote:

> zram's handle variable can store handle of zsmalloc in case of
> compressing efficiently. Otherwise, it stores point of page descriptor.
> This patch clean up the mess by union struct.
> 
> changelog
>   * from v1
> 	- none(new add in v2)
> 
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>


Not sure if the BUILD_BUG is completely needed since it's pretty well
assumed that sizeof(unsigned long) == sizeof(void *) but it does provide
some safety is someone tries to change the type of handle.

Acked-by: <sjenning@linux.vnet.ibm.com>

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
