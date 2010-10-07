Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 66B746B004A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 08:32:06 -0400 (EDT)
Message-ID: <4CADBDB1.9060608@redhat.com>
Date: Thu, 07 Oct 2010 14:31:45 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 04/12] Add memory slot versioning and use it to provide
 fast guest write interface
References: <1286207794-16120-1-git-send-email-gleb@redhat.com> <1286207794-16120-5-git-send-email-gleb@redhat.com>
In-Reply-To: <1286207794-16120-5-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 10/04/2010 05:56 PM, Gleb Natapov wrote:
> Keep track of memslots changes by keeping generation number in memslots
> structure. Provide kvm_write_guest_cached() function that skips
> gfn_to_hva() translation if memslots was not changed since previous
> invocation.

btw, this patch (and patch 5, and perhaps more) can be applied 
independently.  If you like, you can submit them before the patch set is 
complete to reduce your queue length.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
