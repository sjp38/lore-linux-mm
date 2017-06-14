Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 71A626B02B4
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 15:26:48 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id p66so5243871oia.0
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 12:26:48 -0700 (PDT)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id a16si386814oth.242.2017.06.14.12.26.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 12:26:47 -0700 (PDT)
Received: by mail-oi0-x230.google.com with SMTP id s3so6401016oia.0
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 12:26:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170614124520.GA8537@dhcp22.suse.cz>
References: <149739530052.20686.9000645746376519779.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149739530612.20686.14760671150202647861.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170614124520.GA8537@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 14 Jun 2017 12:26:46 -0700
Message-ID: <CAPcyv4hEYJrW=Pv+ON5+EG4iLUjX2XRW3u+kSsMa8J5qh-KeVg@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] mm: improve readability of transparent_hugepage_enabled()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Jun 14, 2017 at 5:45 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Tue 13-06-17 16:08:26, Dan Williams wrote:
>> Turn the macro into a static inline and rewrite the condition checks for
>> better readability in preparation for adding another condition.
>>
>> Cc: Jan Kara <jack@suse.cz>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
>> [ross: fix logic to make conversion equivalent]
>> Acked-by: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>
> This is really a nice deobfuscation! Please note this will conflict with
> http://lkml.kernel.org/r/1496415802-30944-1-git-send-email-rppt@linux.vnet.ibm.com
>
>
> Trivial to resolve but I thought I should give you a heads up.

Hmm, I'm assuming that vma_is_dax() should override PRCTL_THP_DISABLE?
...and while we're there should vma_is_dax() also override
VM_NOHUGEPAGE? This is with the assumption that the reason to turn off
huge pages is to avoid mm pressure, dax exerts no such pressure.

> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks for the heads up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
