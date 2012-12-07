Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 09EE16B006E
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 11:37:20 -0500 (EST)
Message-ID: <50C21B3F.4030104@codeaurora.org>
Date: Fri, 07 Dec 2012 08:37:19 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Debugging: Keep track of page owners
References: <20121205011242.09C8667F@kernel.stglabs.ibm.com> <50BF61E0.1060307@codeaurora.org> <50BF88D0.9050209@linux.vnet.ibm.com>
In-Reply-To: <50BF88D0.9050209@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: akpm@osdl.org, linux-mm@kvack.org

On 12/5/2012 9:48 AM, Dave Hansen wrote:

>> MIGRATE_CMA pages (with CONFIG_CMA) will always have pagetype != mtype
>> so CMA pages will always show up here even though they are considered
>> movable pages. That's probably not what you want here.
>
> What do you think the the right way to handle it is?  Should we just
> check explicitly for CMA pages and punt on them?
>

That sounds like a reasonable approach to start.

Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
