Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id F2B0F6B0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 14:38:05 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 18 Feb 2013 14:38:04 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 73783C9001D
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 14:37:52 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1IJborf348282
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 14:37:51 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1IJbe0T026034
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 12:37:41 -0700
Message-ID: <512282FF.2050005@linux.vnet.ibm.com>
Date: Mon, 18 Feb 2013 13:37:35 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 0/8] zswap: compressed swap caching
References: <1360780731-11708-1-git-send-email-sjenning@linux.vnet.ibm.com> <511EFB05.3020700@gmail.com>
In-Reply-To: <511EFB05.3020700@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 02/15/2013 09:20 PM, Ric Mason wrote:
> On 02/14/2013 02:38 AM, Seth Jennings wrote:
<snip>
>>
>> Some addition performance metrics regarding the performance
>> improvements and I/O reductions that can be achieved using zswap as
>> measured by SPECjbb are provided here:
>>
>> http://ibm.co/VCgHvM
> 
> I see this link.  You mentioned that "When a user enables zswap and
> the hardware accelerator, zswap simply passes the pages to be
> compressed or decompressed off to the accelerator instead of
> performing the work in software". Then how can user enable hardware
> accelerator, there are option in UEFI or ... ?

zswap uses the cryptographic API for accessing compressor modules.  In
the case of Power7+, we have a crypto API driver (crypto/842.c) which
wraps calls to the real driver (drivers/crypto/nx/nx-842.c) which
makes the hardware calls.

To use a compressor module, use the zswap.compressor attribute on the
kernel parameter.  For P7+, for exmaple:

zswap.compressor=842

> 
>> These results include runs on x86 and new results on Power7+ with
>> hardware compression acceleration.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
