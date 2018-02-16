Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C2FDE6B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 09:02:20 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id l7so957125wmh.4
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 06:02:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h195si1279169wmd.266.2018.02.16.06.02.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Feb 2018 06:02:18 -0800 (PST)
Subject: Re: [PATCH] mm: don't defer struct page initialization for Xen pv
 guests
References: <20180216133726.30813-1-jgross@suse.com>
 <20180216135940.GQ7275@dhcp22.suse.cz>
From: Juergen Gross <jgross@suse.com>
Message-ID: <1424bb25-7d6a-ee21-83b4-0e90369d6132@suse.com>
Date: Fri, 16 Feb 2018 15:02:17 +0100
MIME-Version: 1.0
In-Reply-To: <20180216135940.GQ7275@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, akpm@linux-foundation.org, stable@vger.kernel.org, Pavel Tatashin <pasha.tatashin@oracle.com>

On 16/02/18 14:59, Michal Hocko wrote:
> [CC Pavel]
> 
> On Fri 16-02-18 14:37:26, Juergen Gross wrote:
>> Commit f7f99100d8d95dbcf09e0216a143211e79418b9f ("mm: stop zeroing
>> memory during allocation in vmemmap") broke Xen pv domains in some
>> configurations, as the "Pinned" information in struct page of early
>> page tables could get lost.
> 
> Could you be more specific please?

In which way? Do you want to see the resulting crash in the commit
message or some more background information?

> 
>> Avoid this problem by not deferring struct page initialization when
>> running as Xen pv guest.
>>
>> Cc: <stable@vger.kernel.org> #4.15
> Fixes: f7f99100d8d9 ("mm: stop zeroing memory during allocation in vmemmap")
> 
> please

Okay.


Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
