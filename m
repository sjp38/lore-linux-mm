Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id E88D76B0285
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 14:26:51 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id t9so11129365ioa.9
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 11:26:51 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s14-v6sor4627512iti.41.2018.03.23.11.26.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Mar 2018 11:26:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180323174447.55F35636@viggo.jf.intel.com>
References: <20180323174447.55F35636@viggo.jf.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 23 Mar 2018 11:26:49 -0700
Message-ID: <CA+55aFwEC1O+6qRc35XwpcuLSgJ+0GP6ciqw_1Oc-msX=efLvQ@mail.gmail.com>
Subject: Re: [PATCH 00/11] Use global pages with PTI
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, the arch/x86 maintainers <x86@kernel.org>, namit@vmware.com

On Fri, Mar 23, 2018 at 10:44 AM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> This adds one major change from the last version of the patch set
> (present in the last patch).  It makes all kernel text global for non-
> PCID systems.  This keeps kernel data protected always, but means that
> it will be easier to find kernel gadgets via meltdown on old systems
> without PCIDs.  This heuristic is, I think, a reasonable one and it
> keeps us from having to create any new pti=foo options

Sounds sane.

The patches look reasonable, but I hate seeing a patch series like
this where the only ostensible reason is performance, and there are no
performance numbers anywhere..

             Linus
