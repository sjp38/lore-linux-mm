Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id E82286B0389
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 09:55:41 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id p77so53138182ywg.3
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 06:55:41 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r27si639762ybd.171.2017.03.15.06.55.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 06:55:40 -0700 (PDT)
Subject: Re: [PATCH v7 1/3] x86/mm: Adapt MODULES_END based on Fixmap section
 size
References: <20170314170508.100882-1-thgarnie@google.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <799314af-e529-bc83-6322-54f5f5d28a40@oracle.com>
Date: Wed, 15 Mar 2017 09:52:54 -0400
MIME-Version: 1.0
In-Reply-To: <20170314170508.100882-1-thgarnie@google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Jonathan Corbet <corbet@lwn.net>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Kees Cook <keescook@chromium.org>, Juergen Gross <jgross@suse.com>, Andy Lutomirski <luto@kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, Chris Wilson <chris@chris-wilson.co.uk>, Andy Lutomirski <luto@amacapital.net>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, Jiri Kosina <jikos@kernel.org>, Matt Fleming <matt@codeblueprint.co.uk>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Rusty Russell <rusty@rustcorp.com.au>, Paolo Bonzini <pbonzini@redhat.com>, Borislav Petkov <bp@suse.de>, Christian Borntraeger <borntraeger@de.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Stanislaw Gruszka <sgruszka@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, Joerg Roedel <joro@8bytes.org>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, lguest@lists.ozlabs.org, kvm@vger.kernel.org, kernel-hardening@lists.openwall.com

On 03/14/2017 01:05 PM, Thomas Garnier wrote:
> This patch aligns MODULES_END to the beginning of the Fixmap section.
> It optimizes the space available for both sections. The address is
> pre-computed based on the number of pages required by the Fixmap
> section.
>
> It will allow GDT remapping in the Fixmap section. The current
> MODULES_END static address does not provide enough space for the kernel
> to support a large number of processors.
>
> Signed-off-by: Thomas Garnier <thgarnie@google.com>

For Xen bits (and to some extent bare-metal):

Reviewed-and-Tested-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
