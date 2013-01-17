Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 4F8466B0006
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 16:55:40 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Thu, 17 Jan 2013 16:55:39 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id C08A938C801C
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 16:55:34 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0HLtY2Y316578
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 16:55:34 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0HLtXRo005914
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 16:55:34 -0500
Message-ID: <50F8734C.2080906@linux.vnet.ibm.com>
Date: Thu, 17 Jan 2013 13:55:24 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] Reproducible OOM with just a few sleeps
References: <201301172104.r0HL4F9k005128@como.maths.usyd.edu.au>
In-Reply-To: <201301172104.r0HL4F9k005128@como.maths.usyd.edu.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au
Cc: psz@maths.usyd.edu.au, 695182@bugs.debian.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 01/17/2013 01:04 PM, paul.szabo@sydney.edu.au wrote:
>>> On my large machine, 'free' fails to show about 2GB memory ...
>> You probably have a memory hole. ...
>> The e820 map (during early boot in dmesg) or /proc/iomem will let you
>> locate your memory holes.
> 
> Now that my machine is running an amd64 kernel, 'free' shows total Mem
> 65854128 (up from 64447796 with PAE kernel), and I do not see much
> change in /proc/iomem output (below). Is that as should be?

Yeah, that all looks sane.  Your increased memory is because your 64GB
machine had some of its memory mapped _above_ the 64GB physical memory
limit that PAE has.

/proc/iomem is generally just a dump of what the hardware *is*, so it
shouldn't change between kernels.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
