Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id EA44D6B004A
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 07:58:05 -0400 (EDT)
Received: by yhr47 with SMTP id 47so967335yhr.14
        for <linux-mm@kvack.org>; Sat, 31 Mar 2012 04:58:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFPAmTQs9dOpQTaXU=6Or66YU+my_CnPw33TE4h++YArBNa38g@mail.gmail.com>
References: <CAFPAmTQs9dOpQTaXU=6Or66YU+my_CnPw33TE4h++YArBNa38g@mail.gmail.com>
Date: Sat, 31 Mar 2012 07:58:04 -0400
Message-ID: <CAFPAmTT19hFymnFftLkV1jQjYmJgyk3y4b-kTXO3VP1YCR-_fQ@mail.gmail.com>
Subject: [PATCH 0/19 v2] mmu: arch/mm: Port OOM changes to arch page fault handlers.
From: Kautuk Consul <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux@lists.openrisc.net, linux-am33-list@redhat.com, microblaze-uclinux@itee.uq.edu.au, linux-m68k@lists.linux-m68k.org, linux-m32r-ja@ml.linux-m32r.org, linux-ia64@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-cris-kernel@axis.com, linux-sh@vger.kernel.org, linux-parisc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

Commit d065bd810b6deb67d4897a14bfe21f8eb526ba99
(mm: retry page fault when blocking on disk transfer) and
commit 37b23e0525d393d48a7d59f870b3bc061a30ccdb
(x86,mm: make pagefault killable)

The above commits introduced changes into the x86 pagefault handler
for making the page fault handler retryable as well as killable.

These changes reduce the mmap_sem hold time, which is crucial
during OOM killer invocation.

I was facing hang and livelock problems on my ARM and MIPS boards when
I invoked OOM by running the stress_32k.c test-case attached to this email.

Since both the ARM and MIPS porting changes were accepted, me and my
co-worker decided to take the initiative to port these changes to all other
MMU based architectures.

This is v2 of this patch set as there were some problems with the v1 of this
patchset:
- Whitespace issues as reported by David Miller and Joe Perches
- In 2 of the patches, the write(or equivalent) local variable has
been removed from the
  page fault handler because it is not really needed anymore with the
advent of the "flags"
  local variable. Thanks to Geert Uytterhoeven for that.
- The powerpc patch for this has been removed as this has already been
done by someone
  else for powerpc.

At the moment, 8 of these patches have Acked these patches as valid.
I have included their ACKed-By headers for them in their respective
arch patches.

And thanks to Guan Xuetao for actually testing this out on unicore32.

Rest of the arch owners: Please review these patches.

Signed-off-by: Mohd. Faris <mohdfarisq2010@gmail.com>
Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
