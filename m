Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id A46A16B0008
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 04:23:28 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id z68so19356808qkb.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 01:23:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f26si427098qtc.65.2018.11.15.01.23.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 01:23:27 -0800 (PST)
Subject: Re: [PATCH RFC 3/6] kexec: export PG_offline to VMCOREINFO
References: <20181114211704.6381-1-david@redhat.com>
 <20181114211704.6381-4-david@redhat.com>
 <20181115061923.GA3971@dhcp-128-65.nay.redhat.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <685892a9-3a56-8e8c-dbe7-8b1159067a6b@redhat.com>
Date: Thu, 15 Nov 2018 10:23:13 +0100
MIME-Version: 1.0
In-Reply-To: <20181115061923.GA3971@dhcp-128-65.nay.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Baoquan He <bhe@redhat.com>, Omar Sandoval <osandov@fb.com>, Arnd Bergmann <arnd@arndb.de>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Lianbo Jiang <lijiang@redhat.com>, Borislav Petkov <bp@alien8.de>, "Michael S. Tsirkin" <mst@redhat.com>

On 15.11.18 07:19, Dave Young wrote:
> Hi David,
> 
> On 11/14/18 at 10:17pm, David Hildenbrand wrote:
>> Let's export PG_offline via PAGE_OFFLINE_MAPCOUNT_VALUE, so
>> makedumpfile can directly skip pages that are logically offline and the
>> content therefore stale.
> 
> It would be good to copy some background info from cover letter to the
> patch description so that we can get better understanding why this is
> needed now.

Yes, will add more detail!

> 
> BTW, Lianbo is working on a documentation of the vmcoreinfo exported
> fields. Ccing him so that he is aware of this.
> 
> Also cc Boris,  although I do not want the doc changes blocks this
> he might have different opinion :)

I'll be happy to help updating documentation (or updating it myself if
the doc updates go in first).

-- 

Thanks,

David / dhildenb
