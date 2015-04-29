Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3A69C6B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 18:09:40 -0400 (EDT)
Received: by iecrt8 with SMTP id rt8so53928609iec.0
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 15:09:40 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id t18si573666icc.89.2015.04.29.15.09.39
        for <linux-mm@kvack.org>;
        Wed, 29 Apr 2015 15:09:39 -0700 (PDT)
Message-ID: <554156A1.3010903@kernel.org>
Date: Wed, 29 Apr 2015 15:09:37 -0700
From: Andy Lutomirski <luto@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Hardening memory maunipulation.
References: <1430321975-13626-1-git-send-email-citypw@gmail.com>
In-Reply-To: <1430321975-13626-1-git-send-email-citypw@gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Chang <citypw@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: spender@grsecurity.net, keescook@chromium.org

On 04/29/2015 08:39 AM, Shawn Chang wrote:
> From: Shawn C <citypw@gmail.com>
>
> Hi kernel maintainers,
>
> It won't allow the address above the TASK_SIZE being mmap'ed( or mprotect'ed).
> This patch is from PaX/Grsecurity.
>
> Thanks for your review time!

Does this actually reduce the attack surface of anything?

These functions all search for vmas.  If there's a vma outside of the 
user range, we have a problem.

Also, that use of TASK_SIZE is IMO ridiculous.  Shouldn't be TASK_SIZE_MAX?

--Andy, who is annoyed every time another pointless TIF_IA32 reference, 
even hidden in a macro, makes it into the kernel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
