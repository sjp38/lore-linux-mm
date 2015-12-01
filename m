Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id B9A986B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 19:42:29 -0500 (EST)
Received: by qkao63 with SMTP id o63so66379889qka.2
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 16:42:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s79si47751722qgs.31.2015.11.30.16.42.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 16:42:29 -0800 (PST)
Subject: Re: [PATCHv2] arm: Update all mm structures with section adjustments
References: <1447892054-8095-1-git-send-email-labbott@fedoraproject.org>
 <CAGXu5j+y1m9oONvCQg=MgrkwAgUV5OChoAY=q6vvyGNExY1Zjg@mail.gmail.com>
 <CAGXu5j+P2Y_dSJo=tK7hBNX_7hOiG23rA7nXcQ99csNA0_CSvA@mail.gmail.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <565CECF1.6090101@redhat.com>
Date: Mon, 30 Nov 2015 16:42:25 -0800
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+P2Y_dSJo=tK7hBNX_7hOiG23rA7nXcQ99csNA0_CSvA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@fedoraproject.org>
Cc: Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 11/30/2015 03:40 PM, Kees Cook wrote:
> On Thu, Nov 19, 2015 at 11:10 AM, Kees Cook <keescook@chromium.org> wrote:
>> On Wed, Nov 18, 2015 at 4:14 PM, Laura Abbott <labbott@fedoraproject.org> wrote:
>>> Currently, when updating section permissions to mark areas RO
>>> or NX, the only mm updated is current->mm. This is working off
>>> the assumption that there are no additional mm structures at
>>> the time. This may not always hold true. (Example: calling
>>> modprobe early will trigger a fork/exec). Ensure all mm structres
>>> get updated with the new section information.
>>>
>>> Signed-off-by: Laura Abbott <labbott@fedoraproject.org>
>>
>> This looks right to me. :)
>>
>> Reviewed-by: Kees Cook <keescook@chromium.org>
>>
>> Russell, does this work for you?
>
> Did this end up in the patch tracker? (I just sent a patch that'll
> collide with this... I'm happy to do the fix up.)
>

I put this in the patch tracker this morning.
  
> -Kees
>

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
