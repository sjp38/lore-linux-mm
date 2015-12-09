Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id B67056B0258
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 09:07:55 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so30450264pac.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 06:07:55 -0800 (PST)
Received: from mail1.bemta12.messagelabs.com (mail1.bemta12.messagelabs.com. [216.82.251.8])
        by mx.google.com with ESMTPS id f18si12970192pfj.115.2015.12.09.06.07.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 06:07:55 -0800 (PST)
Subject: Re: m(un)map kmalloc buffers to userspace
References: <5667128B.3080704@sigmadesigns.com>
 <20151209135544.GE30907@dhcp22.suse.cz>
From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Message-ID: <566835B6.9010605@sigmadesigns.com>
Date: Wed, 9 Dec 2015 15:07:50 +0100
MIME-Version: 1.0
In-Reply-To: <20151209135544.GE30907@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sebastian Frias <sebastian_frias@sigmadesigns.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 09/12/2015 14:55, Michal Hocko wrote:
> On Tue 08-12-15 18:25:31, Sebastian Frias wrote:
>> Hi,
>>
>> We are porting a driver from Linux 3.4.39+ to 4.1.13+, CPU is Cortex-A9.
>>
>> The driver maps kmalloc'ed memory to user space.
> 
> This sounds like a terrible idea to me. Why don't you simply use the
> page allocator directly? Try to imagine what would happen if you mmaped
> a kmalloc with a size which is not page aligned? mmaped memory uses
> whole page granularity.

According to the source code, this kernel module calls

  kmalloc(1 << 17, GFP_KERNEL | __GFP_REPEAT);

I suppose kmalloc() would return page-aligned memory?

(Note: the kernel module was originally written for 2.4 and was updated
inconsistently over the years.)

Regards.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
