Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 1ED826B005A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 10:46:15 -0400 (EDT)
Received: by yhr47 with SMTP id 47so600389yhr.14
        for <linux-mm@kvack.org>; Tue, 17 Jul 2012 07:46:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1207170929290.13599@router.home>
References: <1342221125.17464.8.camel@lorien2>
	<alpine.DEB.2.00.1207140216040.20297@chino.kir.corp.google.com>
	<CAOJsxLE3dDd01WaAp5UAHRb0AiXn_s43M=Gg4TgXzRji_HffEQ@mail.gmail.com>
	<1342407840.3190.5.camel@lorien2>
	<alpine.DEB.2.00.1207160257420.11472@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1207160915470.28952@router.home>
	<alpine.DEB.2.00.1207161253240.29012@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1207161506390.32319@router.home>
	<alpine.DEB.2.00.1207161642420.18232@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1207170929290.13599@router.home>
Date: Tue, 17 Jul 2012 17:46:13 +0300
Message-ID: <CAOJsxLECr7yj9cMs4oUJQjkjZe9x-6mvk76ArGsQzRWBi8_wVw@mail.gmail.com>
Subject: Re: [PATCH TRIVIAL] mm: Fix build warning in kmem_cache_create()
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, Shuah Khan <shuah.khan@hp.com>, glommer@parallels.com, js1304@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, shuahkhan@gmail.com

On Mon, 16 Jul 2012, David Rientjes wrote:
>> > The kernel cannot check everything and will blow up in unexpected ways if
>> > someone codes something stupid. There are numerous debugging options that
>> > need to be switched on to get better debugging information to investigate
>> > deper. Adding special code to replicate these checks is bad.
>>
>> Disagree, CONFIG_SLAB does not blow up for a NULL name string and just
>> corrupts userspace.

On Tue, Jul 17, 2012 at 5:36 PM, Christoph Lameter <cl@linux.com> wrote:
> Ohh.. So far we only had science fiction. Now kernel fiction.... If you
> could corrupt userspace using sysfs with a NULL string then you'd first
> need to fix sysfs support.
>
> And if you really want to be totally safe then I guess you need to audit
> the kernel and make sure that every core kernel function that takes a
> string argument does check for it to be NULL just in case.

Well, even SLUB checks for !name in mainline so that's definitely
worth including unconditionally. Furthermore, the size related checks
certainly make sense and I don't see any harm in having them as well.

As for "in_interrupt()", I really don't see the point in keeping that
around. We could push it down to mm/slab.c in "__kmem_cache_create()"
if we wanted to.

                                Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
