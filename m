Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id A7AE66B007B
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 08:16:56 -0500 (EST)
Received: by mail-oa0-f41.google.com with SMTP id k14so522963oag.14
        for <linux-mm@kvack.org>; Fri, 07 Dec 2012 05:16:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121206145020.93fd7128.akpm@linux-foundation.org>
References: <1354810175-4338-1-git-send-email-js1304@gmail.com>
	<20121206145020.93fd7128.akpm@linux-foundation.org>
Date: Fri, 7 Dec 2012 22:16:55 +0900
Message-ID: <CAAmzW4N-=uXBdgjbkdL=aNVtKvvXZs-6BNgpDzi7CLkeo0-jBg@mail.gmail.com>
Subject: Re: [RFC PATCH 0/8] remove vm_struct list management
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org, Vivek Goyal <vgoyal@redhat.com>

2012/12/7 Andrew Morton <akpm@linux-foundation.org>:
> On Fri,  7 Dec 2012 01:09:27 +0900
> Joonsoo Kim <js1304@gmail.com> wrote:
>
>> I'm not sure that "7/8: makes vmlist only for kexec" is fine.
>> Because it is related to userspace program.
>> As far as I know, makedumpfile use kexec's output information and it only
>> need first address of vmalloc layer. So my implementation reflect this
>> fact, but I'm not sure. And now, I don't fully test this patchset.
>> Basic operation work well, but I don't test kexec. So I send this
>> patchset with 'RFC'.
>
> Yes, this is irritating.  Perhaps Vivek or one of the other kexec
> people could take a look at this please - if would obviously be much
> better if we can avoid merging [patch 7/8] at all.

I'm not sure, but I almost sure that [patch 7/8] have no problem.
In kexec.c, they write an address of vmlist and offset of vm_struct's
address field.
It imply that user for this information doesn't have any other
information about vm_struct,
and they can't use other field of vm_struct. They can use *only* address field.
So, remaining just one vm_struct for vmlist which represent first area
of vmalloc layer
may be safe.

But, kexec people may be very helpful to validate this patch.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
