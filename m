Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1CD376B024A
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 18:46:08 -0400 (EDT)
Message-ID: <4C350398.5070504@redhat.com>
Date: Wed, 07 Jul 2010 18:45:44 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 05/12] Export __get_user_pages_fast.
References: <1278433500-29884-1-git-send-email-gleb@redhat.com> <1278433500-29884-6-git-send-email-gleb@redhat.com>
In-Reply-To: <1278433500-29884-6-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On 07/06/2010 12:24 PM, Gleb Natapov wrote:
> KVM will use it to try and find a page without falling back to slow
> gup. That is why get_user_pages_fast() is not enough.
>
> Signed-off-by: Gleb Natapov<gleb@redhat.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
