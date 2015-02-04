Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7DA8B6B00A5
	for <linux-mm@kvack.org>; Wed,  4 Feb 2015 15:42:24 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id fb4so6380879wid.2
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 12:42:24 -0800 (PST)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id vz2si5324543wjc.85.2015.02.04.12.42.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Feb 2015 12:42:22 -0800 (PST)
Received: by mail-wi0-f180.google.com with SMTP id h11so6382022wiw.1
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 12:42:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <E484D272A3A61B4880CDF2E712E9279F4591C3EC@hhmail02.hh.imgtec.org>
References: <1422970639-7922-1-git-send-email-daniel.sanders@imgtec.com>
	<1422970639-7922-2-git-send-email-daniel.sanders@imgtec.com>
	<54D27403.90000@iki.fi>
	<E484D272A3A61B4880CDF2E712E9279F4591C3EC@hhmail02.hh.imgtec.org>
Date: Wed, 4 Feb 2015 22:42:22 +0200
Message-ID: <CAOJsxLF453qWJitGGjn+gMcJwXdXo4wLtmGzhVYJ3j5xOYNHWg@mail.gmail.com>
Subject: Re: [PATCH 1/5] LLVMLinux: Correct size_index table before replacing
 the bootstrap kmem_cache_node.
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Sanders <Daniel.Sanders@imgtec.com>
Cc: Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Feb 4, 2015 at 10:38 PM, Daniel Sanders
<Daniel.Sanders@imgtec.com> wrote:
> I don't believe the bug to be LLVM specific but GCC doesn't normally enco=
unter the problem. I haven't been able to identify exactly what GCC is doin=
g better (probably inlining) but it seems that GCC is managing to optimize =
 to the point that it eliminates the problematic allocations. This theory i=
s supported by the fact that GCC can be made to fail in the same way by cha=
nging inline, __inline, __inline__, and __always_inline in include/linux/co=
mpiler-gcc.h such that they don't actually inline things.

OK, makes sense. Please include that explanation in the changelog and
drop use proper "slab" prefix instead of the confusing "LLVMLinux"
prefix in the subject line.

- Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
