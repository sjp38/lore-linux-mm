Received: by nz-out-0102.google.com with SMTP id i11so466416nzi
        for <linux-mm@kvack.org>; Thu, 08 Jun 2006 13:10:12 -0700 (PDT)
Message-ID: <5c49b0ed0606081310q5771e8d1s55acef09b405922b@mail.gmail.com>
Date: Thu, 8 Jun 2006 13:10:11 -0700
From: "Nate Diller" <nate.diller@gmail.com>
Subject: Re: [PATCH] mm: tracking dirty pages -v6
In-Reply-To: <1149770654.4408.71.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20060525135534.20941.91650.sendpatchset@lappy>
	 <Pine.LNX.4.64.0606062056540.1507@blonde.wat.veritas.com>
	 <1149770654.4408.71.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On 6/8/06, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
>
> People expressed the need to track dirty pages in shared mappings.
>
> Linus outlined the general idea of doing that through making clean
> writable pages write-protected and taking the write fault.
>
> This patch does exactly that, it makes pages in a shared writable
> mapping write-protected. On write-fault the pages are marked dirty and
> made writable. When the pages get synced with their backing store, the
> write-protection is re-instated.

Does this mean that processes dirtying pages via mmap are now subject
to write throttling?  That could dramatically change the performance
for tasks with a working set larger than 10% of memory.

NATE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
