Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 92E876B0038
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 13:19:01 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id hz20so3228629lab.39
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 10:19:00 -0700 (PDT)
Received: from mail-la0-x236.google.com (mail-la0-x236.google.com [2a00:1450:4010:c03::236])
        by mx.google.com with ESMTPS id c5si17506440lah.117.2014.10.16.10.18.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Oct 2014 10:18:59 -0700 (PDT)
Received: by mail-la0-f54.google.com with SMTP id gm9so3243037lab.41
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 10:18:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1411562649-28231-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1411562649-28231-1-git-send-email-a.ryabinin@samsung.com>
Date: Thu, 16 Oct 2014 21:18:58 +0400
Message-ID: <CAJOtW+7pONPaB+G_j4XJEeXtWOFYgbvSyz-QPNdTfJOUc11WLg@mail.gmail.com>
Subject: Re: [PATCH v3 00/13] Kernel address sanitizer - runtime memory debugger.
From: Yuri Gribov <tetra2005@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-kbuild@vger.kernel.org, x86@kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>

On Wed, Sep 24, 2014 at 4:43 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> Hi.
>
> This is a third iteration of kerenel address sanitizer (KASan).
>
> ...
>
> KASAN uses compile-time instrumentation for checking every memory access, therefore you
> will need a fresh GCC >= v5.0.0.

FYI I've backported Kasan patches to GCC 4.9 branch. They'll be in
upcoming 4.9 release.

-Y

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
