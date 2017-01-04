Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7E9196B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 06:44:52 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id u5so968531620pgi.7
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 03:44:52 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e22si72228958pli.289.2017.01.04.03.44.51
        for <linux-mm@kvack.org>;
        Wed, 04 Jan 2017 03:44:51 -0800 (PST)
Date: Wed, 4 Jan 2017 11:44:50 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCHv6 00/11] CONFIG_DEBUG_VIRTUAL for arm64
Message-ID: <20170104114449.GA18193@arm.com>
References: <1483464113-1587-1-git-send-email-labbott@redhat.com>
 <edc8eaa2-5414-506c-1dad-f2404ef19c81@gmail.com>
 <b3de65da-8a74-2510-268e-34516cc2de77@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b3de65da-8a74-2510-268e-34516cc2de77@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, x86@kernel.org, kasan-dev@googlegroups.com, Ingo Molnar <mingo@redhat.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, David Vrabel <david.vrabel@citrix.com>, Kees Cook <keescook@chromium.org>, Marc Zyngier <marc.zyngier@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, Eric Biederman <ebiederm@xmission.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoffer Dall <christoffer.dall@linaro.org>

On Tue, Jan 03, 2017 at 03:25:53PM -0800, Laura Abbott wrote:
> On 01/03/2017 02:56 PM, Florian Fainelli wrote:
> > On 01/03/2017 09:21 AM, Laura Abbott wrote:
> >> Happy New Year!
> >>
> >> This is a very minor rebase from v5. It only moves a few headers around.
> >> I think this series should be ready to be queued up for 4.11.
> > 
> > FWIW:
> > 
> > Tested-by: Florian Fainelli <f.fainelli@gmail.com>
> > 
> 
> Thanks!
> 
> > How do we get this series included? I would like to get the ARM 32-bit
> > counterpart included as well (will resubmit rebased shortly), but I have
> > no clue which tree this should be going through.
> > 
> 
> I was assuming this would go through the arm64 tree unless Catalin/Will
> have an objection to that.

Yup, I was planning to pick it up for 4.11.

Florian -- does your series depend on this? If so, then I'll need to
co-ordinate with Russell (probably via a shared branch that we both pull)
if you're aiming for 4.11 too.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
