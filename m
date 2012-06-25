Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id E24826B0377
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 13:11:15 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 25 Jun 2012 11:11:14 -0600
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 1FFA1C90073
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 13:11:09 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5PHBAaY144096
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 13:11:10 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5PHB2Rh012696
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 14:11:08 -0300
Message-ID: <4FE89BA1.3030709@linux.vnet.ibm.com>
Date: Mon, 25 Jun 2012 12:10:57 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] zsmalloc: add generic path and remove x86 dependency
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com> <1340640878-27536-3-git-send-email-sjenning@linux.vnet.ibm.com> <20120625165915.GA20464@kroah.com>
In-Reply-To: <20120625165915.GA20464@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On 06/25/2012 11:59 AM, Greg Kroah-Hartman wrote:
> On Mon, Jun 25, 2012 at 11:14:37AM -0500, Seth Jennings wrote:
>> This patch adds generic pages mapping methods that
>> work on all archs in the absence of support for
>> local_tlb_flush_kernel_range() advertised by the
>> arch through __HAVE_LOCAL_TLB_FLUSH_KERNEL_RANGE
> 
> Is this #define something that other arches define now?  Or is this
> something new that you are adding here?

Something new I'm adding.

The precedent for this approach is the __HAVE_ARCH_* defines
that let the arch independent stuff know if a generic
function needs to be defined or if there is an arch specific
function.

You can "grep -R __HAVE_ARCH_* arch/x86/" to see the ones
that already exist.

I guess I should have called it
__HAVE_ARCH_LOCAL_TLB_FLUSH_KERNEL_RANGE though, not
__HAVE_LOCAL_TLB_FLUSH_KERNEL_RANGE.

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
