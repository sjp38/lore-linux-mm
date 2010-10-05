Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 43CFE6B007B
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 21:29:38 -0400 (EDT)
Message-ID: <4CAA7F77.7010605@redhat.com>
Date: Mon, 04 Oct 2010 21:29:27 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 04/12] Add memory slot versioning and use it to provide
 fast guest write interface
References: <1286207794-16120-1-git-send-email-gleb@redhat.com> <1286207794-16120-5-git-send-email-gleb@redhat.com>
In-Reply-To: <1286207794-16120-5-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On 10/04/2010 11:56 AM, Gleb Natapov wrote:
> Keep track of memslots changes by keeping generation number in memslots
> structure. Provide kvm_write_guest_cached() function that skips
> gfn_to_hva() translation if memslots was not changed since previous
> invocation.
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
