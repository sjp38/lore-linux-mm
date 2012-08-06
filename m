Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 779D66B0044
	for <linux-mm@kvack.org>; Sun,  5 Aug 2012 23:41:38 -0400 (EDT)
Message-ID: <1344224494.3053.5.camel@lorien2>
Subject: Re: [PATCH TRIVIAL] mm: Fix build warning in kmem_cache_create()
From: Shuah Khan <shuah.khan@hp.com>
Reply-To: shuah.khan@hp.com
Date: Sun, 05 Aug 2012 21:41:34 -0600
In-Reply-To: <CAOJsxLGjnMxs9qERG5nCfGfcS3jy6Rr54Ac36WgVnOtP_pDYgQ@mail.gmail.com>
References: <1342221125.17464.8.camel@lorien2>
	 <CAOJsxLGjnMxs9qERG5nCfGfcS3jy6Rr54Ac36WgVnOtP_pDYgQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: cl@linux.com, glommer@parallels.com, js1304@gmail.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, shuahkhan@gmail.com

On Mon, 2012-07-30 at 13:18 +0300, Pekka Enberg wrote:
> On Sat, Jul 14, 2012 at 2:12 AM, Shuah Khan <shuah.khan@hp.com> wrote:
> > The label oops is used in CONFIG_DEBUG_VM ifdef block and is defined
> > outside ifdef CONFIG_DEBUG_VM block. This results in the following
> > build warning when built with CONFIG_DEBUG_VM disabled. Fix to move
> > label oops definition to inside a CONFIG_DEBUG_VM block.
> >
> > mm/slab_common.c: In function a??kmem_cache_createa??:
> > mm/slab_common.c:101:1: warning: label a??oopsa?? defined but not used
> > [-Wunused-label]
> >
> > Signed-off-by: Shuah Khan <shuah.khan@hp.com>
> 
> I merged this as an obvious and safe fix for current merge window. We
> need to clean this up properly for v3.7.

Thanks for merging the obvious fix. I was on vacation for the last two
weeks, and just got back. I sent another patch that restructures the
debug and non-debug code right before I went on vacation. Didn't get a
chance to look at the responses (if any). Will get working on following
up and re-working and re-sending the patch as needed this week.

-- Shuah


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
