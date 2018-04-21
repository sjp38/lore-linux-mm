Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id F3BE76B0003
	for <linux-mm@kvack.org>; Sat, 21 Apr 2018 19:56:57 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id g67-v6so1268874otb.10
        for <linux-mm@kvack.org>; Sat, 21 Apr 2018 16:56:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w3-v6sor4218995oiw.186.2018.04.21.16.56.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 21 Apr 2018 16:56:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFqt6zZoU0O_w6stq+47ndBUY+yqk950nsyP_1ShTArQfxsSeQ@mail.gmail.com>
References: <20180421210529.GA27238@jordon-HP-15-Notebook-PC>
 <20180421213401.GF14610@bombadil.infradead.org> <CAFqt6zZoU0O_w6stq+47ndBUY+yqk950nsyP_1ShTArQfxsSeQ@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 21 Apr 2018 16:56:56 -0700
Message-ID: <CAPcyv4jzyofOTrymiQchXyRdNPZ+BXn3-W3hjCJ4mvtpDD2g4w@mail.gmail.com>
Subject: Re: [PATCH v3] fs: dax: Adding new return type vm_fault_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sat, Apr 21, 2018 at 2:54 PM, Souptick Joarder <jrdr.linux@gmail.com> wrote:
> On Sun, Apr 22, 2018 at 3:04 AM, Matthew Wilcox <willy@infradead.org> wrote:
>> On Sun, Apr 22, 2018 at 02:35:29AM +0530, Souptick Joarder wrote:
>>> Use new return type vm_fault_t for fault handler. For
>>> now, this is just documenting that the function returns
>>> a VM_FAULT value rather than an errno. Once all instances
>>> are converted, vm_fault_t will become a distinct type.
>>>
>>> commit 1c8f422059ae ("mm: change return type to vm_fault_t")
>>>
>>> There was an existing bug inside dax_load_hole()
>>> if vm_insert_mixed had failed to allocate a page table,
>>> we'd return VM_FAULT_NOPAGE instead of VM_FAULT_OOM.
>>> With new vmf_insert_mixed() this issue is addressed.
>>>
>>> vm_insert_mixed_mkwrite has inefficiency when it returns
>>> an error value, driver has to convert it to vm_fault_t
>>> type. With new vmf_insert_mixed_mkwrite() this limitation
>>> will be addressed.
>>>
>>> As new function vmf_insert_mixed_mkwrite() only called
>>> from fs/dax.c, so keeping both the changes in a single
>>> patch.
>>>
>>> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
>>
>> Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
>>
>> There's a couple of minor things which could be tidied up, but not worth
>> doing them as a revision to this patch.
>
> Which tree this patch will go through ? mm or fsdevel ?

nvdimm, since that tree has some pending reworks for dax-vs-truncate.
