Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 7F3656B0069
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 13:38:18 -0500 (EST)
Message-ID: <50F5A215.5020708@redhat.com>
Date: Tue, 15 Jan 2013 13:38:13 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFCv3][PATCH 2/3] fix kvm's use of __pa() on percpu areas
References: <20130109185904.DD641DCE@kernel.stglabs.ibm.com> <20130109185905.0DCFC236@kernel.stglabs.ibm.com>
In-Reply-To: <20130109185905.0DCFC236@kernel.stglabs.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gleb Natapov <gleb@redhat.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Marcelo Tosatti <mtosatti@redhat.com>

On 01/09/2013 01:59 PM, Dave Hansen wrote:
> In short, it is illegal to call __pa() on an address holding
> a percpu variable.  The times when this actually matters are
> pretty obscure (certain 32-bit NUMA systems), but it _does_
> happen.  It is important to keep KVM guests working on these
> systems because the real hardware is getting harder and
> harder to find.
>
> This bug manifested first by me seeing a plain hang at boot
> after this message:
>
> 	CPU 0 irqstacks, hard=f3018000 soft=f301a000
>
> or, sometimes, it would actually make it out to the console:
>
> [    0.000000] BUG: unable to handle kernel paging request at ffffffff
>
> I eventually traced it down to the KVM async pagefault code.
> This can be worked around by disabling that code either at
> compile-time, or on the kernel command-line.

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
