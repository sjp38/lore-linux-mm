Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C1BB19000BD
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 14:34:25 -0400 (EDT)
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 16 Sep 2011 14:34:21 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8GIXWsB432880
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 14:33:36 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8GIXVm9014486
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 14:33:32 -0400
Message-ID: <4E739677.4020708@linux.vnet.ibm.com>
Date: Fri, 16 Sep 2011 13:33:27 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com> <20110909203447.GB19127@kroah.com> <4E6ACE5B.9040401@vflare.org> <4E6E18C6.8080900@linux.vnet.ibm.com> <4E6EB802.4070109@vflare.org> <4E6F7DA7.9000706@linux.vnet.ibm.com> <4E6FC8A1.8070902@vflare.org> <4E72284B.2040907@linux.vnet.ibm.com> <4E738B81.2070005@vflare.org>
In-Reply-To: <4E738B81.2070005@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Greg KH <greg@kroah.com>, gregkh@suse.de, devel@driverdev.osuosl.org, dan.magenheimer@oracle.com, cascardo@holoscopio.com, linux-kernel@vger.kernel.org, dave@linux.vnet.ibm.com, linux-mm@kvack.org, brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com

On 09/16/2011 12:46 PM, Nitin Gupta wrote:
> I think replacing allocator every few weeks isn't a good idea. So, I
> guess better would be to let me work for about 2 weeks and try the slab
> based approach.  If nothing works out in this time, then maybe xcfmalloc
> can be integrated after further testing.

Sounds good to me.

> 
> Thanks,
> Nitin
> 

Thanks
--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
