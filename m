Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 2622A6B00BD
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 19:21:16 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id wc18so6878247obb.8
        for <linux-mm@kvack.org>; Mon, 04 Feb 2013 16:21:15 -0800 (PST)
Message-ID: <1360023672.12336.0.camel@kernel.cn.ibm.com>
Subject: Re: [PATCH v2] Make frontswap+cleancache and its friend be
 modularized.
From: Ric Mason <ric.masonn@gmail.com>
Date: Mon, 04 Feb 2013 18:21:12 -0600
In-Reply-To: <510FD073.1060307@linux.vnet.ibm.com>
References: <1359750184-23408-1-git-send-email-konrad.wilk@oracle.com>
	 <1359881520.1328.14.camel@kernel.cn.ibm.com>
	 <510FD073.1060307@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Konrad Rzeszutek Wilk <konrad@kernel.org>, dan.magenheimer@oracle.com, konrad.wilk@oracle.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, ngupta@vflare.org, rcj@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Mon, 2013-02-04 at 09:14 -0600, Seth Jennings wrote:
> On 02/03/2013 02:52 AM, Ric Mason wrote:
> > Hi Konrad,
> > On Fri, 2013-02-01 at 15:22 -0500, Konrad Rzeszutek Wilk wrote:
> > 
> > I have already enable frontswap,cleancache,zcache,
> >  FRONTSWAP [=y]  
> >  CLEANCACHE [=y]
> >  ZCACHE [=y]
> > But all of knode under /sys/kernel/debug/frontswap and cleancache still
> > zero, my swap device is enable, where I miss?
> 
> Did you pass "zcache" in the kernel boot parameters?

Thanks Seth, I think it should be add to kernel-parameters.txt.

> 
> Seth
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
