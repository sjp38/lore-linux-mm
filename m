Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 461106B025B
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 19:27:40 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id n128so16553502pfn.3
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 16:27:40 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id sl3si20021783pac.220.2016.01.08.16.27.39
        for <linux-mm@kvack.org>;
        Fri, 08 Jan 2016 16:27:39 -0800 (PST)
Subject: Re: [RFC 13/13] x86/mm: Try to preserve old TLB entries using PCID
References: <cover.1452294700.git.luto@kernel.org>
 <c4125ff6333c97d3ce00e5886b809b7c20594585.1452294700.git.luto@kernel.org>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <569053F9.7060002@linux.intel.com>
Date: Fri, 8 Jan 2016 16:27:37 -0800
MIME-Version: 1.0
In-Reply-To: <c4125ff6333c97d3ce00e5886b809b7c20594585.1452294700.git.luto@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 01/08/2016 03:15 PM, Andy Lutomirski wrote:
> + * The guiding principle of this code is that TLB entries that have
> + * survived more than a small number of context switches are mostly
> + * useless, so we don't try very hard not to evict them.

Big ack on that.  The original approach tried to keep track of the full
4k worth of possible PCIDs, it also needed an additional cpumask (which
it dynamically allocated) for where the PCID was active in addition to
the normal "where has this mm been" mask.

That's a lot of extra data to mangle, and I can definitely see your
approach as being nicer, *IF* the hardware isn't doing something useful
with the other 9 bits of PCID that you're throwing away. ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
