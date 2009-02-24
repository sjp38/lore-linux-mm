Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 053396B00AD
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 07:23:59 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH RFC] vm_unmap_aliases: allow callers to inhibit TLB flush
Date: Tue, 24 Feb 2009 23:23:05 +1100
References: <49416494.6040009@goop.org> <200902232013.43054.nickpiggin@yahoo.com.au> <49A2F885.8030407@goop.org>
In-Reply-To: <49A2F885.8030407@goop.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902242323.05879.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Arjan van de Ven <arjan@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 24 February 2009 06:27:01 Jeremy Fitzhardinge wrote:
> Nick Piggin wrote:
> > Here's a start for you. I think it gets rid of all the dead code and
> > data without introducing any actual conditional compilation...
>
> OK, I can get started with this, but it will need to be a runtime
> switch; a Xen kernel running native is just a normal kernel, and I don't
> think we want to disable lazy flushes in that case.

That's fine, just make it a constant 1 if !CONFIG_XEN? And otherwise
a variable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
