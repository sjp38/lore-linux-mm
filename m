Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 3E5C66B007E
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 22:03:57 -0400 (EDT)
Message-ID: <4F98AD2D.3070900@kernel.org>
Date: Thu, 26 Apr 2012 11:04:29 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] zsmalloc: make zsmalloc portable
References: <1335334994-22138-1-git-send-email-minchan@kernel.org> <1335334994-22138-7-git-send-email-minchan@kernel.org> <4F980AFE.60901@vflare.org> <4F982862.4050302@linux.vnet.ibm.com>
In-Reply-To: <4F982862.4050302@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/26/2012 01:37 AM, Seth Jennings wrote:

> Hey Minchan,
> 
> Thanks for the patches!
> 
> On 04/25/2012 09:32 AM, Nitin Gupta wrote:
>> I think Seth was working on this improvement but not sure about the
>> current status. Seth?
> 
> Yes, I looked at this option, and it is very clean and portable.
> 
> Unfortunately, IIRC, with our rate of mapping/unmapping,
> flush_tlb_kernel_range() causes an IPI storm that effective
> stalls the machine.
> 
> I'll apply your patch and try it out.


Seth, Thanks!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
