Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E3106B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 18:25:08 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 136so240229wmu.10
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 15:25:08 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z33si10841846wrz.517.2017.10.10.15.25.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 15:25:07 -0700 (PDT)
Date: Tue, 10 Oct 2017 15:25:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] proc: do not show VmExe bigger than total executable
 virtual memory
Message-Id: <20171010152504.c0b84899a95e0bcd79b73290@linux-foundation.org>
In-Reply-To: <150728955451.743749.11276392315459539583.stgit@buzz>
References: <150728955451.743749.11276392315459539583.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 06 Oct 2017 14:32:34 +0300 Konstantin Khlebnikov <khlebnikov@yandex-team.ru> wrote:

> If start_code / end_code pointers are screwed then "VmExe" could be bigger
> than total executable virtual memory and "VmLib" becomes negative:
> 
> VmExe:	  294320 kB
> VmLib:	18446744073709327564 kB
> 
> VmExe and VmLib documented as text segment and shared library code size.
> 
> Now their sum will be always equal to mm->exec_vm which sums size of
> executable and not writable and not stack areas.

When does this happen?  What causes start_code/end_code to get "screwed"?

When these pointers are screwed, the result of end_code-start_code can
still be wrong while not necessarily being negative, yes?  In which
case we'll still display incorrect output?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
