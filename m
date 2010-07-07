Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F34536B0246
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 18:43:49 -0400 (EDT)
Message-ID: <4C3501ED.7040805@redhat.com>
Date: Wed, 07 Jul 2010 18:38:37 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 04/12] Provide special async page fault handler when
 async PF capability is detected
References: <1278433500-29884-1-git-send-email-gleb@redhat.com> <1278433500-29884-5-git-send-email-gleb@redhat.com>
In-Reply-To: <1278433500-29884-5-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On 07/06/2010 12:24 PM, Gleb Natapov wrote:
> When async PF capability is detected hook up special page fault handler
> that will handle async page fault events and bypass other page faults to
> regular page fault handler.
>
> Signed-off-by: Gleb Natapov<gleb@redhat.com>

I had some concerns with this patch, but it looks like patch
10/12 addresses all of those, so ...

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
