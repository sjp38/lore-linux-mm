Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 570DF6B0069
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 20:20:25 -0400 (EDT)
Message-ID: <4FEBA354.9030609@kernel.org>
Date: Thu, 28 Jun 2012 09:20:36 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] zsmalloc: add generic path and remove x86 dependency
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com> <1340640878-27536-3-git-send-email-sjenning@linux.vnet.ibm.com> <4FEA9A0D.4020000@kernel.org> <4FEB5A7E.8040500@linux.vnet.ibm.com>
In-Reply-To: <4FEB5A7E.8040500@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On 06/28/2012 04:09 AM, Seth Jennings wrote:

> On 06/27/2012 12:28 AM, Minchan Kim wrote:
>>> +{
>>> +	if (area->vm)
>>> +		return 0;
>>
>>
>> Just out of curiosity.
>> When do we need above check?
> 
> I did this in the case that there was a race between the for
> loop in zs_init(), calling zs_cpu_notifier(), and a CPU
> coming online.  I've never seen the condition hit, but if it
> did, it would leak memory without this check.
> 


Could you add this as a comment?



> I would move the cpu notifier registration after the loop in
> zs_init(), but then I could miss a cpu up event and we
> wouldn't have the needed per-cpu resources for mapping.
> 
> All other suggestions are accepted.  Thanks for the feedback!
> 



Thanks!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
