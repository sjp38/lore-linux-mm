Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id CCCE26B002B
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 14:15:15 -0400 (EDT)
Received: from /spool/local
	by e6.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 10 Aug 2012 14:15:14 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id B42056E803C
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 14:15:08 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7AIF4qr172450
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 14:15:06 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7AIE2gW008729
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 12:14:03 -0600
Message-ID: <50254F69.2000409@linux.vnet.ibm.com>
Date: Fri, 10 Aug 2012 13:14:01 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] promote zcache from staging
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com> <5021795A.5000509@linux.vnet.ibm.com> <5024067F.3010602@linux.vnet.ibm.com> <2e9ccb4f-1339-4c26-88dd-ea294b022127@default>
In-Reply-To: <2e9ccb4f-1339-4c26-88dd-ea294b022127@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, Kurt Hackel <kurt.hackel@oracle.com>

On 08/09/2012 03:20 PM, Dan Magenheimer wrote
> I also wonder if you have anything else unusual in your
> test setup, such as a fast swap disk (mine is a partition
> on the same rotating disk as source and target of the kernel build,
> the default install for a RHEL6 system)?

I'm using a normal SATA HDD with two partitions, one for
swap and the other an ext3 filesystem with the kernel source.

> Or have you disabled cleancache?

Yes, I _did_ disable cleancache.  I could see where having
cleancache enabled could explain the difference in results.

> Or have you changed any sysfs parameters or
> other kernel files?

No.

> And are you using 512M of physical memory or relying on
> kernel boot parameters to reduce visible memory

Limited with mem=512M boot parameter.

> ... and
> if the latter have you confirmed with /proc/meminfo?

Yes, confirmed.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
