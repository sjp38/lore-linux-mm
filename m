Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A29D060021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 03:56:55 -0500 (EST)
Message-ID: <4B1E1513.3020000@kernel.org>
Date: Tue, 08 Dec 2009 17:57:55 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/vmalloc: don't use vmalloc_end
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com> <20091207153552.0fadf335.akpm@linux-foundation.org> <4B1E1B1B0200007800024345@vpn.id2.novell.com> <4B1E0E56.8020003@kernel.org> <4B1E1EE60200007800024364@vpn.id2.novell.com>
In-Reply-To: <4B1E1EE60200007800024364@vpn.id2.novell.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jan Beulich <JBeulich@novell.com>
Cc: tony.luck@intel.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Geert Uytterhoeven <geert@linux-m68k.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello,

On 12/08/2009 05:39 PM, Jan Beulich wrote:
>>>> Tejun Heo <tj@kernel.org> 08.12.09 09:29 >>>
>> Hmm... it shouldn't be building.
> 
> How can it not be building? It's in vmalloc.c (which must be built) and not
> inside any conditional.

Ah... yes, right.  Somehow I was thinking it lived in percpu.c.  Sorry
about that.  Probably the right thing to do is to wrap the function
inside CONFIG ifdef's.  I'll prep a patch.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
