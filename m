Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 24EA76B0022
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 10:16:15 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 4 Feb 2013 10:16:11 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 68D3C38C8084
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 10:15:39 -0500 (EST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r14FFcaF12779698
	for <linux-mm@kvack.org>; Mon, 4 Feb 2013 10:15:39 -0500
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r14FFKc6019052
	for <linux-mm@kvack.org>; Mon, 4 Feb 2013 08:15:21 -0700
Message-ID: <510FD073.1060307@linux.vnet.ibm.com>
Date: Mon, 04 Feb 2013 09:14:59 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] Make frontswap+cleancache and its friend be modularized.
References: <1359750184-23408-1-git-send-email-konrad.wilk@oracle.com> <1359881520.1328.14.camel@kernel.cn.ibm.com>
In-Reply-To: <1359881520.1328.14.camel@kernel.cn.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Konrad Rzeszutek Wilk <konrad@kernel.org>, dan.magenheimer@oracle.com, konrad.wilk@oracle.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, ngupta@vflare.org, rcj@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 02/03/2013 02:52 AM, Ric Mason wrote:
> Hi Konrad,
> On Fri, 2013-02-01 at 15:22 -0500, Konrad Rzeszutek Wilk wrote:
> 
> I have already enable frontswap,cleancache,zcache,
>  FRONTSWAP [=y]  
>  CLEANCACHE [=y]
>  ZCACHE [=y]
> But all of knode under /sys/kernel/debug/frontswap and cleancache still
> zero, my swap device is enable, where I miss?

Did you pass "zcache" in the kernel boot parameters?

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
