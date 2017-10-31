Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5A6814403DA
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 19:35:45 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id n33so2630495ioi.7
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 16:35:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e75sor1317899ita.139.2017.10.31.16.35.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Oct 2017 16:35:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171031223201.2CAC2B48@viggo.jf.intel.com>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223201.2CAC2B48@viggo.jf.intel.com>
From: Kees Cook <keescook@google.com>
Date: Tue, 31 Oct 2017 16:35:43 -0700
Message-ID: <CAGXu5j+xgZoDktKyYEtOcH7XGDRzH2_=gDs5Zj9rXx0817Tbew@mail.gmail.com>
Subject: Re: [PATCH 08/23] x86, kaiser: only populate shadow page tables for userspace
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, x86@kernel.org

On Tue, Oct 31, 2017 at 3:32 PM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
> KAISER has two copies of the page tables: one for the kernel and
> one for when we are running in userspace.  There is also a kernel
> portion of each of the page tables: the part that *maps* the
> kernel.

I wonder if it might make sense to update
arch/x86/mm/debug_pagetables.c to show the shadow table in some way?
Right now, only the "real" page tables are visible there.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
