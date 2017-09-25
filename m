Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0856B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 15:27:04 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id d6so10053979wrd.7
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 12:27:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w48sor2412577wrb.12.2017.09.25.12.27.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Sep 2017 12:27:03 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <83b023da-e9f5-2957-981e-5b0e71e9bf1b@oracle.com>
References: <a5d279cb-a015-f74c-2e40-a231aa7f7a8c@redhat.com>
 <20170919214224.19561-1-mike.kravetz@oracle.com> <6fafdae8-4fea-c967-f5cd-d22c205608fa@gmail.com>
 <83b023da-e9f5-2957-981e-5b0e71e9bf1b@oracle.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Mon, 25 Sep 2017 21:26:42 +0200
Message-ID: <CAKgNAkhJEyK=LhFj9W-RgSv+ET64d+MaEAQ41y5eximfQmYPDw@mail.gmail.com>
Subject: Re: [patch v2] mremap.2: Add description of old_size == 0 functionality
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-man <linux-man@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Jann Horn <jannh@google.com>, Florian Weimer <fweimer@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

Hi Mike,

On 25 September 2017 at 18:33, Mike Kravetz <mike.kravetz@oracle.com> wrote:
> On 09/20/2017 12:25 AM, Michael Kerrisk (man-pages) wrote:

[...]

>> I've applied this, and added Reviewed-by tags for Florian and Jann.
>> But, I think it's also worth noting the older, now disallowed, behavior,
>> and why the behavior was changed. So I added a note in BUGS:
>>
>>     BUGS
>>        Before Linux 4.14, if old_size was zero and the  mapping  referred
>>        to  by  old_address  was  a private mapping (mmap(2) MAP_PRIVATE),
>>        mremap() created a new private mapping unrelated to  the  original
>>        mapping.   This behavior was unintended and probably unexpected in
>>        user-space applications (since the intention  of  mremap()  is  to
>>        create  a new mapping based on the original mapping).  Since Linux
>>        4.14, mremap() fails with the error EINVAL in this scenario.
>>
>> Does that seem okay?
>
> Sorry for the late reply Michael,  I've been away for a few days.
>
> Yes, the above seems okay.  Thanks for your help with this.

You're welcome. Thanks for checking it over!

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
