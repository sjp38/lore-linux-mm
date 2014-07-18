Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id E92656B0035
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 14:37:42 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so5497558pdj.28
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 11:37:42 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id ta1si6852172pac.50.2014.07.18.11.37.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jul 2014 11:37:41 -0700 (PDT)
Message-ID: <53C96946.4090304@zytor.com>
Date: Fri, 18 Jul 2014 11:36:54 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] arm64,ia64,ppc,s390,sh,tile,um,x86,mm: Remove default
 gate area
References: <70f331f59e620dc4e66bd3fa095e6f6b744b532b.1405281639.git.luto@amacapital.net> <CALCETrXG6nL4K=Er+kv5-CXBDVa0TLg9yR6iePnMyE2ufXgKkw@mail.gmail.com> <20140718101416.GB1818@arm.com> <53C8F4DF.8020103@nod.at> <CALCETrXve-=N5yzqDw2YQee4BmC6sb8GYWYJcV2780V38OuJiQ@mail.gmail.com>
In-Reply-To: <CALCETrXve-=N5yzqDw2YQee4BmC6sb8GYWYJcV2780V38OuJiQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Richard Weinberger <richard@nod.at>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org, Fenghua Yu <fenghua.yu@intel.com>, X86 ML <x86@kernel.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Ingo Molnar <mingo@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, Nathan Lynch <Nathan_Lynch@mentor.com>, "linux390@de.ibm.com" <linux390@de.ibm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Chris Metcalf <cmetcalf@tilera.com>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, Paul Mackerras <paulus@samba.org>, Jeff Dike <jdike@addtoit.com>, "user-mode-linux-devel@lists.sourceforge.net" <user-mode-linux-devel@lists.sourceforge.net>

On 07/18/2014 09:53 AM, Andy Lutomirski wrote:
> 
> Splitting this will be annoying: I'd probably have to add a flag asking for
> the new behavior, update all the arches, then remove the flag.  The chance
> of screwing up bisectability in the process seems pretty high.  This seems
> like overkill for a patch that mostly deletes code.
> 
> Akpm, can you take this?
> 

I'm fine with it as-is.

Acked-by: H. Peter Anvin <hpa@linux.intel.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
