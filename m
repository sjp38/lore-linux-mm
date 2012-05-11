Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id B36268D0047
	for <linux-mm@kvack.org>; Fri, 11 May 2012 15:35:23 -0400 (EDT)
Date: Fri, 11 May 2012 15:29:15 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 3/4] zsmalloc use zs_handle instead of void *
Message-ID: <20120511192915.GD3785@phenom.dumpdata.com>
References: <4FABD503.4030808@vflare.org>
 <4FABDA9F.1000105@linux.vnet.ibm.com>
 <20120510151941.GA18302@kroah.com>
 <4FABECF5.8040602@vflare.org>
 <20120510164418.GC13964@kroah.com>
 <4FABF9D4.8080303@vflare.org>
 <20120510173322.GA30481@phenom.dumpdata.com>
 <4FAC4E3B.3030909@kernel.org>
 <8473859b-42f3-4354-b5ba-fd5b8cbac22f@default>
 <4FAC59F6.4080503@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FAC59F6.4080503@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> > there are other users that require a different interface
> > or a more precise abstract API, zsmalloc could then
> > evolve to meet the needs of multiple users.  But I think
> 
> 
> At least, zram is also primary user and it also has such mess although it's not severe than zcache. zram->table[index].handle sometime has real (void*) handle, sometime (struct page*).

Yikes. Yeah that needs to be fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
