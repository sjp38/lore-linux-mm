Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id C1F066B0675
	for <linux-mm@kvack.org>; Fri, 11 May 2018 12:39:16 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id l14-v6so2056206lfc.16
        for <linux-mm@kvack.org>; Fri, 11 May 2018 09:39:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y20-v6sor357829lfk.14.2018.05.11.09.39.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 May 2018 09:39:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4i1=q45aqSHXkWvQQgXBqkwuHR2ZxXWmpbeQxptXCcAFA@mail.gmail.com>
References: <20180511163421.GA32728@jordon-HP-15-Notebook-PC> <CAPcyv4i1=q45aqSHXkWvQQgXBqkwuHR2ZxXWmpbeQxptXCcAFA@mail.gmail.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Fri, 11 May 2018 22:09:13 +0530
Message-ID: <CAFqt6zZitXMDzX7gX2xvMO1AzW7_RikgZ0ssRucYn6OWb3ON_w@mail.gmail.com>
Subject: Re: [PATCH v4] dax: Change return type to vm_fault_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, zi.yan@cs.rutgers.edu, Ross Zwisler <ross.zwisler@linux.intel.com>, "Huang, Ying" <ying.huang@intel.com>, Michal Hocko <mhocko@suse.com>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Fri, May 11, 2018 at 10:04 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> On Fri, May 11, 2018 at 9:34 AM, Souptick Joarder <jrdr.linux@gmail.com> wrote:
>> Use new return type vm_fault_t for fault handler. For
>> now, this is just documenting that the function returns
>> a VM_FAULT value rather than an errno. Once all instances
>> are converted, vm_fault_t will become a distinct type.
>>
>> Commit 1c8f422059ae ("mm: change return type to vm_fault_t")
>>
>> Previously vm_insert_mixed() returns err which driver
>> mapped into VM_FAULT_* type. The new function
>> vmf_insert_mixed() will replace this inefficiency by
>> returning VM_FAULT_* type.
>>
>> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
>> Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
>> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
>> ---
>> v2: Modified the change log
>>
>> v3: Updated the change log and
>>     added Ross in review list
>>
>> v4: Addressed David's comment.
>>     Changes in huge_memory.c put
>>     together in a single patch that
>>     it is bisectable in furture
>
> Thanks, I'll carry this in the nvdimm tree since it collides with some
> work-in progress development.

Thanks Dan :)
