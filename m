Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id DA5E16B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 20:21:35 -0400 (EDT)
Message-ID: <4FECF489.4080008@intel.com>
Date: Fri, 29 Jun 2012 08:19:21 +0800
From: Alex Shi <alex.shi@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] x86: add local_tlb_flush_kernel_range()
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com> <1340640878-27536-4-git-send-email-sjenning@linux.vnet.ibm.com> <4FEA9FDD.6030102@kernel.org> <4FEAA4AA.3000406@intel.com> <4FEAA7A1.9020307@kernel.org> <90bcc2c8-bcac-4620-b3c0-6b65f8d9174d@default> <4FEB5204.3090707@linux.vnet.ibm.com> <4FEBBB5C.5000505@intel.com> <4FEC7668.3000403@linux.vnet.ibm.com>
In-Reply-To: <4FEC7668.3000403@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Konrad Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, "H. Peter Anvin" <hpa@zytor.com>

On 06/28/2012 11:21 PM, Seth Jennings wrote:

> On 06/27/2012 09:03 PM, Alex Shi wrote:
>> Peter Anvin is merging my TLB patch set into tip tree, x86/mm branch.
> 
> Great! I don't know the integration path of this tree.  Will
> these patches go into mainline in the next merge window from
> here?
> 


$git clone git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git

and get the branch of x86/mm

> --
> Seth
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
