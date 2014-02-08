Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f181.google.com (mail-vc0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 224686B0069
	for <linux-mm@kvack.org>; Sat,  8 Feb 2014 14:54:27 -0500 (EST)
Received: by mail-vc0-f181.google.com with SMTP id ie18so3720159vcb.12
        for <linux-mm@kvack.org>; Sat, 08 Feb 2014 11:54:26 -0800 (PST)
Received: from mail-ve0-f180.google.com (mail-ve0-f180.google.com [209.85.128.180])
        by mx.google.com with ESMTPS id uo10si2823713vec.132.2014.02.08.11.54.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 08 Feb 2014 11:54:26 -0800 (PST)
Received: by mail-ve0-f180.google.com with SMTP id db12so3891283veb.11
        for <linux-mm@kvack.org>; Sat, 08 Feb 2014 11:54:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52F68528.30104@gentoo.org>
References: <CALCETrWu6wvb4M7UwOdqxNUfSmKV2eZ96qMufAQPF7cJD1oz2w@mail.gmail.com>
 <20140207195555.GA18916@nautica> <CALCETrWZvz85hxPGYhgHoF4yp06QkP4SxWQBSxFqmTyCqhE3LA@mail.gmail.com>
 <52F66641.4040405@gentoo.org> <CALCETrVrnX6gWNBOdVTbLZKYWXRWiOYFNgLb0+Sk-bqXsbPc7Q@mail.gmail.com>
 <52F671D0.1060907@gentoo.org> <CALCETrW5Uh9VgYo6vKVWZtK_yVxEyL6B3V2a2HVxY6H+3dSrRQ@mail.gmail.com>
 <52F68299.1040305@gentoo.org> <CALCETrUOPPSb9cOgz1NMqR63Y=kXL1r8nw_WnPyZqTAuweLuaA@mail.gmail.com>
 <52F68528.30104@gentoo.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sat, 8 Feb 2014 11:54:06 -0800
Message-ID: <CALCETrUNgNyMd1CqdmePKxw1+eA-ixKx0=3MvL8Prw7CNOPA9g@mail.gmail.com>
Subject: Re: [V9fs-developer] finit_module broken on 9p because kernel_read
 doesn't work?
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Yao <ryao@gentoo.org>
Cc: Dominique Martinet <dominique.martinet@cea.fr>, Will Deacon <will.deacon@arm.com>, V9FS Developers <v9fs-developer@lists.sourceforge.net>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, Rusty Russell <rusty@rustcorp.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sat, Feb 8, 2014 at 11:27 AM, Richard Yao <ryao@gentoo.org> wrote:
> On 02/08/2014 02:20 PM, Andy Lutomirski wrote:
>> Are we looking at the same patch?
>>
>> + if (is_vmalloc_or_module_addr(data))
>> + pages[index++] = vmalloc_to_page(data);
>>
>> if (is_vmalloc_or_module_addr(data) && !is_vmalloc_addr(data)), the
>> vmalloc_to_page(data) sounds unhealthy.
>>
>> --Andy
>>
>
> Mainline loads all Linux kernel modules into virtual memory. No
> architecture is known to me where this is not the case.
>

Hmm.  I stand corrected.  vmalloc_to_page is safe on module addresses.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
