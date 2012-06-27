Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 400596B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 15:13:28 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 27 Jun 2012 13:13:27 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 3CB5DC40124
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 19:12:32 +0000 (WET)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5RJA8Y6212538
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 13:10:11 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5RJ9wDf021497
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 13:09:59 -0600
Message-ID: <4FEB5A7E.8040500@linux.vnet.ibm.com>
Date: Wed, 27 Jun 2012 14:09:50 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] zsmalloc: add generic path and remove x86 dependency
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com> <1340640878-27536-3-git-send-email-sjenning@linux.vnet.ibm.com> <4FEA9A0D.4020000@kernel.org>
In-Reply-To: <4FEA9A0D.4020000@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On 06/27/2012 12:28 AM, Minchan Kim wrote:
>> +{
>> +	if (area->vm)
>> +		return 0;
> 
> 
> Just out of curiosity.
> When do we need above check?

I did this in the case that there was a race between the for
loop in zs_init(), calling zs_cpu_notifier(), and a CPU
coming online.  I've never seen the condition hit, but if it
did, it would leak memory without this check.

I would move the cpu notifier registration after the loop in
zs_init(), but then I could miss a cpu up event and we
wouldn't have the needed per-cpu resources for mapping.

All other suggestions are accepted.  Thanks for the feedback!

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
