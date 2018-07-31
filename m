Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id BA7566B0003
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 03:35:48 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id k7-v6so3198763ljk.18
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 00:35:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k187-v6sor1077841lfe.108.2018.07.31.00.35.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 00:35:47 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <CA+icZUW0s6AW1swL774vqHufSaKVmzkRr7PjT4uOP7U-CwSUWg@mail.gmail.com>
References: <CA+icZUVQZtvLg6XGwnS-4Zgv+tkCGWw5Ue8_585H_xNOofX76Q@mail.gmail.com>
 <20180730091934.omn2vj6eyh6kaecs@lakrids.cambridge.arm.com>
 <CA+icZUUicAr5hBB9oGtuLhygP4pf39YV9hhrg7GpJQUibZu=ig@mail.gmail.com>
 <20180730094622.av7wlyrkl3rn37mp@lakrids.cambridge.arm.com>
 <CAKwvOdmjD2fvZjZzkehB7ULG06z6Nqs5PjaoEzmyr51wBKQL+w@mail.gmail.com>
 <CA+icZUUR+smEp439Z1TCfBA=_AL+DrNgRxP6i5gb9DqksEAXzg@mail.gmail.com> <CA+icZUW0s6AW1swL774vqHufSaKVmzkRr7PjT4uOP7U-CwSUWg@mail.gmail.com>
From: Sedat Dilek <sedat.dilek@gmail.com>
Date: Tue, 31 Jul 2018 09:35:46 +0200
Message-ID: <CA+icZUXTKL+kO0HzdOfVgyECmW-QKawLipNBv-dh+BgXWURE=Q@mail.gmail.com>
Subject: Re: [llvmlinux] clang fails on linux-next since commit 8bf705d13039
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Desaulniers <ndesaulniers@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Matthias Kaehlcke <mka@chromium.org>, Dmitry Vyukov <dvyukov@google.com>, Greg Hackmann <ghackmann@google.com>, Luis Lozano <llozano@google.com>, Michael Davidson <md@google.com>, Paul Lawrence <paullawrence@google.com>, Sami Tolvanen <samitolvanen@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Ingo Molnar <mingo@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, llvmlinux@lists.linuxfoundation.org, sil2review@lists.osadl.org, JBeulich@suse.com, Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>, Colin Ian King <colin.king@canonical.com>

> Looks good (beyond some ACPI errors).

Fix pending in <linux-pm.git#acpi>...

"ACPICA: AML Parser: ignore dispatcher error status during table load"

[1] https://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm.git/commit/?h=acpi&id=73c2a01c52b657f4a0ead6c95f64c5279efbd000
