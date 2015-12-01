Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8988D6B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 20:10:08 -0500 (EST)
Received: by ioir85 with SMTP id r85so193920504ioi.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 17:10:08 -0800 (PST)
Received: from mail-io0-x229.google.com (mail-io0-x229.google.com. [2607:f8b0:4001:c06::229])
        by mx.google.com with ESMTPS id h91si3493669ioi.167.2015.11.30.17.10.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 17:10:08 -0800 (PST)
Received: by ioc74 with SMTP id 74so192640422ioc.2
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 17:10:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <565CECF1.6090101@redhat.com>
References: <1447892054-8095-1-git-send-email-labbott@fedoraproject.org>
	<CAGXu5j+y1m9oONvCQg=MgrkwAgUV5OChoAY=q6vvyGNExY1Zjg@mail.gmail.com>
	<CAGXu5j+P2Y_dSJo=tK7hBNX_7hOiG23rA7nXcQ99csNA0_CSvA@mail.gmail.com>
	<565CECF1.6090101@redhat.com>
Date: Mon, 30 Nov 2015 17:10:07 -0800
Message-ID: <CAGXu5jK-b_x5e5Qfm_A8i-k3QpjYXv=nQCXeFQknLt=x=+Mn+Q@mail.gmail.com>
Subject: Re: [PATCHv2] arm: Update all mm structures with section adjustments
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Laura Abbott <labbott@fedoraproject.org>, Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Nov 30, 2015 at 4:42 PM, Laura Abbott <labbott@redhat.com> wrote:
> On 11/30/2015 03:40 PM, Kees Cook wrote:
>>
>> On Thu, Nov 19, 2015 at 11:10 AM, Kees Cook <keescook@chromium.org> wrote:
>>>
>>> On Wed, Nov 18, 2015 at 4:14 PM, Laura Abbott <labbott@fedoraproject.org>
>>> wrote:
>>>>
>>>> Currently, when updating section permissions to mark areas RO
>>>> or NX, the only mm updated is current->mm. This is working off
>>>> the assumption that there are no additional mm structures at
>>>> the time. This may not always hold true. (Example: calling
>>>> modprobe early will trigger a fork/exec). Ensure all mm structres
>>>> get updated with the new section information.
>>>>
>>>> Signed-off-by: Laura Abbott <labbott@fedoraproject.org>
>>>
>>>
>>> This looks right to me. :)
>>>
>>> Reviewed-by: Kees Cook <keescook@chromium.org>
>>>
>>> Russell, does this work for you?
>>
>>
>> Did this end up in the patch tracker? (I just sent a patch that'll
>> collide with this... I'm happy to do the fix up.)
>>
>
> I put this in the patch tracker this morning.

Ah-ha, great! I will rebase my change on to it and send a v2
(potentially with additional changes).

-Kees

>
>>
>> -Kees
>>
>
> Thanks,
> Laura



-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
