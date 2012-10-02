Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 37C146B005D
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 18:10:58 -0400 (EDT)
Received: by ied10 with SMTP id 10so19922315ied.14
        for <linux-mm@kvack.org>; Tue, 02 Oct 2012 15:10:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAKFga-fB2JSAscSVi+YUOnFS4Lq4yzH5MHRwxDQBQYZfKAgB6A@mail.gmail.com>
References: <E1T1N2q-0001xm-5X@morero.ard.nu>
	<20120820180037.GV4232@outflux.net>
	<CAKFga-dDRyRwxUu4Sv7QLcoyY5T3xxhw48LP2goWs=avGW0d_A@mail.gmail.com>
	<CAGXu5jJCqABZcMHuQNAaAcUKCEsSqOTn5=DHdwFdJ70zVLsmSQ@mail.gmail.com>
	<CAKFga-fB2JSAscSVi+YUOnFS4Lq4yzH5MHRwxDQBQYZfKAgB6A@mail.gmail.com>
Date: Tue, 2 Oct 2012 15:10:56 -0700
Message-ID: <CAGXu5jLj6qm+Rv3v2pmJqfEmhZBkKJsMUe0aRqxSa=s=w4wbDw@mail.gmail.com>
Subject: Re: [PATCH] hardening: add PROT_FINAL prot flag to mmap/mprotect
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@gmail.com>
Cc: linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, James Morris <jmorris@namei.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org

On Tue, Oct 2, 2012 at 2:41 PM, Ard Biesheuvel <ard.biesheuvel@gmail.com> wrote:
> 2012/10/2 Kees Cook <keescook@chromium.org>:
>>> If desired, additional restrictions can be imposed by using the
>>> security framework, e.g,, disallow non-final r-x mappings.
>>
>> Interesting; what kind of interface did you have in mind?
>
> The 'interface' we use is a LSM .ko which registers handlers for
> mmap() and mprotect() that fail the respective invocations if the
> passed arguments do not adhere to the policy.

Seems reasonable.

>>>> It seems like there needs to be a sensible way to detect that this flag is
>>>> available, though.
>>>
>>> I am open for suggestions to address this. Our particular
>>> implementation of the loader (on an embedded system) tries to set it
>>> on the first mmap invocation, and stops trying if it fails. Not the
>>> most elegant approach, I know ...
>>
>> Actually, that seems easiest.
>>
>> Has there been any more progress on this patch over-all?
>
> No progress.

Al, Andrew, anyone? Thoughts on this?
(First email is https://lkml.org/lkml/2012/8/14/448)

-Kees

-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
