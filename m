Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id C3AC66B0081
	for <linux-mm@kvack.org>; Mon,  7 May 2012 11:03:47 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 7 May 2012 11:03:46 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id DF4DC38C80B0
	for <linux-mm@kvack.org>; Mon,  7 May 2012 11:02:43 -0400 (EDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q47F2fkA094538
	for <linux-mm@kvack.org>; Mon, 7 May 2012 11:02:42 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q47F22Ft030162
	for <linux-mm@kvack.org>; Mon, 7 May 2012 09:02:02 -0600
Message-ID: <4FA7E3D0.2040906@linux.vnet.ibm.com>
Date: Mon, 07 May 2012 10:01:36 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] zsmalloc use zs_handle instead of void *
References: <1336027242-372-1-git-send-email-minchan@kernel.org> <1336027242-372-3-git-send-email-minchan@kernel.org> <4FA28907.9020300@vflare.org> <4FA2A2F0.3030509@linux.vnet.ibm.com> <4FA33DF6.8060107@kernel.org>
In-Reply-To: <4FA33DF6.8060107@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On 05/03/2012 09:24 PM, Minchan Kim wrote:

> On 05/04/2012 12:23 AM, Seth Jennings wrote:
>> The reason I hadn't done it before is that it introduces a checkpatch
>> warning:
>>
>> WARNING: do not add new typedefs
>> #303: FILE: drivers/staging/zsmalloc/zsmalloc.h:19:
>> +typedef void * zs_handle;
>>
> 
> 
> Yes. I did it but I think we are (a) of chapter 5: Typedefs in Documentation/CodingStyle.
> 
>  (a) totally opaque objects (where the typedef is actively used to _hide_
>      what the object is).
> 
> No?


Interesting, seems like checkpatch and CodingStyle aren't completely in
sync here.  Maybe the warning should say "do not add new typedefs unless
allowed by CodingStyle 5(a)" or something.

Works for me though.

Thanks again Minchan!

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
