Message-ID: <48568A69.6040800@zytor.com>
Date: Mon, 16 Jun 2008 08:44:41 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kernel parameter vmalloc size fix
References: <20080616042528.GA3003@darkstar.te-china.tietoenator.com> <20080616080131.GC25632@elte.hu>
In-Reply-To: <20080616080131.GC25632@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Dave Young <hidave.darkstar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, the arch/x86 maintainers <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> 
> hm. Why dont we instead add the size of the hole to the 
> __VMALLOC_RESERVE value instead? There's nothing inherently bad about 
> using vmalloc=16m. The VM area hole is really a kernel-internal 
> abstraction that should not be visible in the usage of the parameter.
> 

Well, the question is are we taking it away from RAM or away from 
vmalloc... there aren't really any other alternatives.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
