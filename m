Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 88C796B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 09:54:50 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id lx4so5074588iec.18
        for <linux-mm@kvack.org>; Fri, 23 May 2014 06:54:50 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id cz7si5405099icc.103.2014.05.23.06.54.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 23 May 2014 06:54:49 -0700 (PDT)
Message-ID: <537F5320.6070402@oracle.com>
Date: Fri, 23 May 2014 09:54:40 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: 3.15.0-rc6: VM_BUG_ON_PAGE(PageTail(page), page)
References: <20140522135828.GA24879@redhat.com> <537ECCDB.8080009@oracle.com> <20140523091631.GA4400@node.dhcp.inet.fi>
In-Reply-To: <20140523091631.GA4400@node.dhcp.inet.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On 05/23/2014 05:16 AM, Kirill A. Shutemov wrote:
> On Fri, May 23, 2014 at 12:21:47AM -0400, Sasha Levin wrote:
>> On 05/22/2014 09:58 AM, Dave Jones wrote:
>>> Not sure if Sasha has already reported this on -next (It's getting hard
>>> to keep track of all the VM bugs he's been finding), but I hit this overnight
>>> on .15-rc6.  First time I've seen this one.
>>
>> Unfortunately I had to disable transhuge/hugetlb in my testing .config since
>> the open issues in -next get hit pretty often, and were unfixed for a while
>> now.
> 
> What THP-related is not fixed by now? collapse hung? what else?

Besides the collapse hang, we have this: https://lkml.org/lkml/2013/3/29/103 .

I know it's not a "real" bug, but DEBUG_PAGEALLOC misbehaving, but it's
still something that makes testing difficult.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
