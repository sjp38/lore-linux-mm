Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id AFBEC6B0002
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 15:58:22 -0400 (EDT)
Message-ID: <516DAD59.2020104@parallels.com>
Date: Tue, 16 Apr 2013 23:58:17 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] mm: Soft-dirty bits for user memory changes tracking
References: <51669E5F.4000801@parallels.com> <51669EB8.2020102@parallels.com> <20130411142417.bb58d519b860d06ab84333c2@linux-foundation.org> <5168089B.7060305@parallels.com> <20130415144619.645394d8ecdb180d7757a735@linux-foundation.org>
In-Reply-To: <20130415144619.645394d8ecdb180d7757a735@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

>>> >From that perspective, the dependency on X86 is awful.  What's the
>>> problem here and what do other architectures need to do to be able to
>>> support the feature?
>>
>> The problem here is that I don't know what free bits are available on
>> page table entries on other architectures. I was about to resolve this
>> for ARM very soon, but for the rest of them I need help from other people.
> 
> Well, this is also a thing arch maintainers can do when they feel a
> need to support the feature on their architecture.  To support them at
> that time we should provide them with a) adequate information in an
> easy-to-find place (eg, a nice comment at the site of the reference x86
> implementation) and b) a userspace test app.

Item a) is presumably covered with two things -- required arch-specific
PTE manipulations are all collected in asm-generic/pgtable.h under the
!CONFIG_HAVE_ARCH_SOFT_DIRTY and the Documentation/vm/soft-dirty.txt
pointed by the API clear_refs_soft_dirty()'s comment.

Item b) was recently merged.

Item c) from Stephen is already sent.

Thank you for your time and help,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
