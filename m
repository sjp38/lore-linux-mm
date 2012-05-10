Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 50C666B004D
	for <linux-mm@kvack.org>; Thu, 10 May 2012 11:11:57 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 10 May 2012 09:11:54 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 1BB261FF001E
	for <linux-mm@kvack.org>; Thu, 10 May 2012 09:11:44 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4AFBX1Q176358
	for <linux-mm@kvack.org>; Thu, 10 May 2012 09:11:34 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4AFCDp4003606
	for <linux-mm@kvack.org>; Thu, 10 May 2012 09:12:13 -0600
Message-ID: <4FABDA9F.1000105@linux.vnet.ibm.com>
Date: Thu, 10 May 2012 10:11:27 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] zsmalloc use zs_handle instead of void *
References: <1336027242-372-1-git-send-email-minchan@kernel.org> <1336027242-372-3-git-send-email-minchan@kernel.org> <4FA28907.9020300@vflare.org> <4FA2A2F0.3030509@linux.vnet.ibm.com> <4FA33DF6.8060107@kernel.org> <20120509201918.GA7288@kroah.com> <4FAB21E7.7020703@kernel.org> <20120510140215.GC26152@phenom.dumpdata.com> <4FABD503.4030808@vflare.org>
In-Reply-To: <4FABD503.4030808@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/10/2012 09:47 AM, Nitin Gupta wrote:

> On 5/10/12 10:02 AM, Konrad Rzeszutek Wilk wrote:
>> struct zs {
>>     void *ptr;
>> };
>>
>> And pass that structure around?
>>
> 
> A minor problem is that we store this handle value in a radix tree node.
> If we wrap it as a struct, then we will not be able to store it directly
> in the node -- the node will have to point to a 'struct zs'. This will
> unnecessarily waste sizeof(void *) for every object stored.


I don't think so. You can use the fact that for a struct zs var, &var
and &var->ptr are the same.

For the structure above:

void * zs_to_void(struct zs *p) { return p->ptr; }
struct zs * void_to_zs(void *p) { return (struct zs *)p; }

Right?

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
