Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id D58BF6B0034
	for <linux-mm@kvack.org>; Thu, 16 May 2013 09:29:21 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id q10so2319212pdj.24
        for <linux-mm@kvack.org>; Thu, 16 May 2013 06:29:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <90a2283bb84b6ce77c9966d76dbceb5c7edffd18.1368702323.git.mst@redhat.com>
References: <cover.1368702323.git.mst@redhat.com> <90a2283bb84b6ce77c9966d76dbceb5c7edffd18.1368702323.git.mst@redhat.com>
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Thu, 16 May 2013 14:29:01 +0100
Message-ID: <CAHkRjk5bHV3WDSnfQLr1MPTXGXXKP+XKRbqL2fn_bPmXt_7=cw@mail.gmail.com>
Subject: Re: [PATCH v2 02/10] arm64: uaccess s/might_sleep/might_fault/
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, David Howells <dhowells@redhat.com>, Hirokazu Takata <takata@linux-m32r.org>, Michal Simek <monstr@monstr.eu>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-m32r@ml.linux-m32r.org, linux-m32r-ja@ml.linux-m32r.org, microblaze-uclinux@itee.uq.edu.au, linux-am33-list@redhat.com, linuxppc-dev@lists.ozlabs.org, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>

On 16 May 2013 12:10, Michael S. Tsirkin <mst@redhat.com> wrote:
> The only reason uaccess routines might sleep
> is if they fault. Make this explicit.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  arch/arm64/include/asm/uaccess.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

For arm64:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
