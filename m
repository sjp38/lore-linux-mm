Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 34BAC6B0113
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 09:39:51 -0400 (EDT)
Received: from /spool/local
	by e2.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 26 Jun 2012 09:39:47 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id BEF1338C806B
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 09:39:14 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5QDdEjx163180
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 09:39:14 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5QJA4kS008579
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 15:10:06 -0400
Message-ID: <4FE9BB7B.2050009@linux.vnet.ibm.com>
Date: Tue, 26 Jun 2012 08:39:07 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] x86: add local_tlb_flush_kernel_range()
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com> <1340640878-27536-4-git-send-email-sjenning@linux.vnet.ibm.com> <CAPbh3rvkKZOuGh_Pn9WpeV5_=vA=k9=x17oa2GoT8fEgRMr+WQ@mail.gmail.com>
In-Reply-To: <CAPbh3rvkKZOuGh_Pn9WpeV5_=vA=k9=x17oa2GoT8fEgRMr+WQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad@darnok.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 06/25/2012 06:01 PM, Konrad Rzeszutek Wilk wrote:
> On Mon, Jun 25, 2012 at 12:14 PM, Seth Jennings
> <sjenning@linux.vnet.ibm.com> wrote:
>> This patch adds support for a local_tlb_flush_kernel_range()
>> function for the x86 arch.  This function allows for CPU-local
>> TLB flushing, potentially using invlpg for single entry flushing,
>> using an arch independent function name.
> 
> What x86 hardware did you use to figure the optimal number?

Actually I didn't.  I used Alex Shi's numbers.

https://lkml.org/lkml/2012/6/25/39

"Like some machine in my hands, balance points is 16 entries
on Romely-EP; while it is at 8 entries on Bloomfield NHM-EP;
and is 256 on IVB mobile CPU. but on model 15 core2 Xeon
using invlpg has nothing help.

For untested machine, do a conservative optimization, same
as NHM CPU."

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
