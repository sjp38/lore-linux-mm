Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4F9E16B007E
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 03:05:27 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id n186so119510745wmn.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 00:05:27 -0800 (PST)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id b4si9087809wme.69.2016.03.03.00.05.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 00:05:26 -0800 (PST)
Received: by mail-wm0-x22a.google.com with SMTP id p65so20470651wmp.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 00:05:25 -0800 (PST)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <20160223011107.FB9B8215@viggo.jf.intel.com>
References: <20160223011107.FB9B8215@viggo.jf.intel.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Thu, 3 Mar 2016 09:05:06 +0100
Message-ID: <CAKgNAkjaZvR-Csf5eEBVi+Eo1HjeXH7Kg0LUL=i1Q-HAJ1EP-A@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/7] System Calls for Memory Protection Keys
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

Hi Dave,

On 23 February 2016 at 02:11, Dave Hansen <dave@sr71.net> wrote:
> As promised, here are the proposed new Memory Protection Keys
> interfaces.  These interfaces make it possible to do something
> with pkeys other than execute-only support.
>
> There are 5 syscalls here.  I'm hoping for reviews of this set
> which can help nail down what the final interfaces will be.
>
> You can find a high-level overview of the feature and the new
> syscalls here:
>
>         https://www.sr71.net/~dave/intel/pkeys.txt

(That's pretty thin...)

> ===============================================================
>
> To use memory protection keys (pkeys), an application absolutely
> needs to be able to set the pkey field in the PTE (obviously has
> to be done in-kernel) and make changes to the "rights" register
> (using unprivileged instructions).
>
> An application also needs to have an an allocator for the keys
> themselves.  If two different parts of an application both want
> to protect their data with pkeys, they first need to know which
> key to use for their individual purposes.
>
> This set introduces 5 system calls, in 3 logical groups:
>
> 1. PTE pkey setting (sys_pkey_mprotect(), patches #1-3)
> 2. Key allocation (sys_pkey_alloc() / sys_pkey_free(), patch #4)
> 3. Rights register manipulation (sys_pkey_set/get(), patch #5)
>
> These patches build on top of "core" support already in the tip tree,
> specifically 62b5f7d013, which can currently be found at:
>
>         http://git.kernel.org/cgit/linux/kernel/git/tip/tip.git/log/?h=mm/pkeys
>
> I have manpages written for some of these syscalls, and I will
> submit a full set of manpages once we've reached some consensus
> on what the interfaces should be.

Please don't do things in this order. Providing man pages up front
make it easier for people to understand, review, and critique the API.
Submitting man pages should be a foundational part of submitting a new
set of interfaces and discussing their design.

Thanks,

Michael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
