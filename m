Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 068A36B0005
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 12:43:21 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id s6so1936314qkh.12
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 09:43:21 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id w34si7678954qtj.277.2018.02.16.09.43.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 09:43:20 -0800 (PST)
Subject: Re: [PATCH] mm: don't defer struct page initialization for Xen pv
 guests
References: <20180216133726.30813-1-jgross@suse.com>
 <20180216135940.GQ7275@dhcp22.suse.cz>
 <1424bb25-7d6a-ee21-83b4-0e90369d6132@suse.com>
From: Pavel Tatashin <pasha.tatashin@ORACLE.COM>
Message-ID: <b277a7be-05d4-67e7-f8ad-50f7865e87fe@oracle.com>
Date: Fri, 16 Feb 2018 09:21:57 -0500
MIME-Version: 1.0
In-Reply-To: <1424bb25-7d6a-ee21-83b4-0e90369d6132@suse.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, akpm@linux-foundation.org, stable@vger.kernel.org

On 02/16/2018 09:02 AM, Juergen Gross wrote:
> On 16/02/18 14:59, Michal Hocko wrote:
>> [CC Pavel]
>>
>> On Fri 16-02-18 14:37:26, Juergen Gross wrote:
>>> Commit f7f99100d8d95dbcf09e0216a143211e79418b9f ("mm: stop zeroing
>>> memory during allocation in vmemmap") broke Xen pv domains in some
>>> configurations, as the "Pinned" information in struct page of early
>>> page tables could get lost.
>>
>> Could you be more specific please?
> 
> In which way? Do you want to see the resulting crash in the commit
> message or some more background information?

Hi Juergen,

Could you please provide details how to reproduce the problem, and crash 
message. Also, information about where exactly xen access struct pages 
before deferred pages are initialized.

Thank you,
Pasha

> 
>>
>>> Avoid this problem by not deferring struct page initialization when
>>> running as Xen pv guest.
>>>
>>> Cc: <stable@vger.kernel.org> #4.15
>> Fixes: f7f99100d8d9 ("mm: stop zeroing memory during allocation in vmemmap")
>>
>> please
> 
> Okay.
> 
> 
> Juergen
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
