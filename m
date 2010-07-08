Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AE57C6B006A
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 00:21:54 -0400 (EDT)
Message-ID: <4C35524E.70104@redhat.com>
Date: Thu, 08 Jul 2010 00:21:34 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 09/12] Retry fault before vmentry
References: <1278433500-29884-1-git-send-email-gleb@redhat.com> <1278433500-29884-10-git-send-email-gleb@redhat.com>
In-Reply-To: <1278433500-29884-10-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On 07/06/2010 12:24 PM, Gleb Natapov wrote:
> When page is swapped in it is mapped into guest memory only after guest
> tries to access it again and generate another fault. To save this fault
> we can map it immediately since we know that guest is going to access
> the page.
>
> Signed-off-by: Gleb Natapov<gleb@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
