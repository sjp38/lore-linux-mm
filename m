Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 691E86B00E7
	for <linux-mm@kvack.org>; Thu, 24 May 2012 15:14:26 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so838393pbb.14
        for <linux-mm@kvack.org>; Thu, 24 May 2012 12:14:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120524120727.6eab2f97.akpm@linux-foundation.org>
References: <1337884054.3292.22.camel@lappy> <20120524120727.6eab2f97.akpm@linux-foundation.org>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Thu, 24 May 2012 21:14:05 +0200
Message-ID: <CA+1xoqcbZWLpvHkOsZY7rijsaryFDvh=pqq=QyDDgo_NfPyCpA@mail.gmail.com>
Subject: Re: mm: kernel BUG at mm/memory.c:1230
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: viro <viro@zeniv.linux.org.uk>, oleg@redhat.com, "a.p.zijlstra" <a.p.zijlstra@chello.nl>, mingo <mingo@kernel.org>, Dave Jones <davej@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>

On Thu, May 24, 2012 at 9:07 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 24 May 2012 20:27:34 +0200
> Sasha Levin <levinsasha928@gmail.com> wrote:
>
>> Hi all,
>>
>> During fuzzing with trinity inside a KVM tools guest, using latest linux=
-next, I've stumbled on the following:
>>
>> [ 2043.098949] ------------[ cut here ]------------
>> [ 2043.099014] kernel BUG at mm/memory.c:1230!
>
> That's
>
> =A0 =A0 =A0 =A0VM_BUG_ON(!rwsem_is_locked(&tlb->mm->mmap_sem));
>
> in zap_pmd_range()?

Yup.

> The assertion was added in Jan 2011 by 14d1a55cd26f1860 ("thp: add
> debug checks for mapcount related invariants"). =A0AFAICT it's just wrong
> on the exit path. =A0Unclear why it's triggering now...

I'm not sure if that's indeed the issue or not, but note that this is
the first time I've managed to trigger that with the fuzzer, and it's
not that easy to reproduce. Which is a bit odd for code that was there
for 4 months...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
