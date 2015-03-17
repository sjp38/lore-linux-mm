Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 093076B006C
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 13:19:24 -0400 (EDT)
Received: by lagg8 with SMTP id g8so14662562lag.1
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 10:19:23 -0700 (PDT)
Received: from forward-corp1f.mail.yandex.net (forward-corp1f.mail.yandex.net. [95.108.130.40])
        by mx.google.com with ESMTPS id d9si11004034laf.139.2015.03.17.10.19.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 10:19:22 -0700 (PDT)
Message-ID: <55086217.6060802@yandex-team.ru>
Date: Tue, 17 Mar 2015 20:19:19 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: trigger panic on bad page or PTE states if panic_on_oops
References: <1426495021-6408-1-git-send-email-borntraeger@de.ibm.com> <20150316110033.GA20546@node.dhcp.inet.fi> <5506BAB6.3080104@de.ibm.com> <20150316121559.GB20546@node.dhcp.inet.fi>
In-Reply-To: <20150316121559.GB20546@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Christian Borntraeger <borntraeger@de.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 16.03.2015 15:15, Kirill A. Shutemov wrote:
> On Mon, Mar 16, 2015 at 12:12:54PM +0100, Christian Borntraeger wrote:
>> Am 16.03.2015 um 12:00 schrieb Kirill A. Shutemov:
>>> On Mon, Mar 16, 2015 at 09:37:01AM +0100, Christian Borntraeger wrote:
>>>> while debugging a memory management problem it helped a lot to
>>>> get a system dump as early as possible for bad page states.
>>>>
>>>> Lets assume that if panic_on_oops is set then the system should
>>>> not continue with broken mm data structures.
>>>
>>> bed_pte is not an oops.
>>
>> I know that this is not an oops, but semantically it is like one.  I certainly
>> want to a way to hard stop the system if something like that happens.
>>
>> Would something like panic_on_mm_error be better?
>
> Or panic_on_taint=<mask> where <mask> is bit-mask of TAINT_* values.
>
> The problem is that TAINT_* will effectevely become part of kernel ABI
> and I'm not sure it's good idea.

Taint bits have associated letters: for example panic_on_taint=OP
panic on out-of-tree or propriate =)

>
> Oopsing on any taint will have limited usefulness, I think.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
