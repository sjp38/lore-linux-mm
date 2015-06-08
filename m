Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 42ED36B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 08:53:39 -0400 (EDT)
Received: by lbcmx3 with SMTP id mx3so80032559lbc.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 05:53:38 -0700 (PDT)
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com. [209.85.217.169])
        by mx.google.com with ESMTPS id dc7si2633637lad.124.2015.06.08.05.53.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 05:53:37 -0700 (PDT)
Received: by lbcmx3 with SMTP id mx3so80031838lbc.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 05:53:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAEVpBaLPDa8tacKKeHmcLMdmYZ86aZBfGqCnAcQ8R=JKSUoagQ@mail.gmail.com>
References: <20150512090156.24768.2521.stgit@buzz>
	<CAEVpBa+-wwf5Q3CwQAAad3V0pJ+uD50uaHKW=EnChLDLOLSAGg@mail.gmail.com>
	<CAEVpBaLPDa8tacKKeHmcLMdmYZ86aZBfGqCnAcQ8R=JKSUoagQ@mail.gmail.com>
Date: Mon, 8 Jun 2015 13:53:36 +0100
Message-ID: <CAEVpBaLmw54FX25Kmrw0owOjDW-ijekS5OJO7iZM3UcV1o3fGA@mail.gmail.com>
Subject: Re: [PATCH RFC 0/3] pagemap: make useable for non-privilege users
From: Mark Williamson <mwilliamson@undo-software.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, kernel list <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>, Linux API <linux-api@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Machek <pavel@ucw.cz>, Mark Seaborn <mseaborn@chromium.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, Daniel James <djames@undo-software.com>, Finn Grimwood <fgrimwood@undo-software.com>

Hi Konstantin,

Would you still be intending to re-submit this patch?  We'd be quite
keen to assist, so if there's anything further I can do please let me
know!

Just to re-confirm - we do think that the patch will solve our problem
(relatively minor changes required on our side).

Thanks,
Mark

On Thu, May 14, 2015 at 7:40 PM, Mark Williamson
<mwilliamson@undo-software.com> wrote:
> Hi Konstantin,
>
> I modified our code to check for the map-exclusive flag where it used
> to compare pageframe numbers.  First tests look pretty promising, so
> this patch looks like a viable approach for us.
>
> Is there anything further we can do to help?
>
> Thanks,
> Mark
>
> On Tue, May 12, 2015 at 12:13 PM, Mark Williamson
> <mwilliamson@undo-software.com> wrote:
>> Hi Konstantin,
>>
>> Thanks very much for continuing to look at this!  It's very much
>> appreciated.  I've been investigating from our end but got caught up
>> in some gnarly details of our pagemap-consuming code.
>>
>> I like the approach and it seems like the information you're exposing
>> will be useful for our application.  I'll test the patch and see if it
>> works for us as-is.
>>
>> Will follow up with any comments on the individual patches.
>>
>> Thanks,
>> Mark
>>
>> On Tue, May 12, 2015 at 10:43 AM, Konstantin Khlebnikov
>> <khlebnikov@yandex-team.ru> wrote:
>>> This patchset tries to make pagemap useable again in the safe way.
>>> First patch adds bit 'map-exlusive' which is set if page is mapped only here.
>>> Second patch restores access for non-privileged users but hides pfn if task
>>> has no capability CAP_SYS_ADMIN. Third patch removes page-shift bits and
>>> completes migration to the new pagemap format (flags soft-dirty and
>>> mmap-exlusive are available only in the new format).
>>>
>>> ---
>>>
>>> Konstantin Khlebnikov (3):
>>>       pagemap: add mmap-exclusive bit for marking pages mapped only here
>>>       pagemap: hide physical addresses from non-privileged users
>>>       pagemap: switch to the new format and do some cleanup
>>>
>>>
>>>  Documentation/vm/pagemap.txt |    3 -
>>>  fs/proc/task_mmu.c           |  178 +++++++++++++++++-------------------------
>>>  tools/vm/page-types.c        |   35 ++++----
>>>  3 files changed, 91 insertions(+), 125 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
