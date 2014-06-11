Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 093976B0173
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 16:04:57 -0400 (EDT)
Received: by mail-ob0-f179.google.com with SMTP id uz6so288484obc.10
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 13:04:56 -0700 (PDT)
Received: from mail-oa0-f45.google.com (mail-oa0-f45.google.com [209.85.219.45])
        by mx.google.com with ESMTPS id i3si37194098obe.72.2014.06.11.13.04.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 13:04:56 -0700 (PDT)
Received: by mail-oa0-f45.google.com with SMTP id o6so295970oag.32
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 13:04:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140611173851.GA5556@MacBook-Pro.local>
References: <CAOJe8K3fy3XFxDdVc3y1hiMAqUCPmkUhECU7j5TT=E=gxwBqHg@mail.gmail.com>
	<20140611173851.GA5556@MacBook-Pro.local>
Date: Thu, 12 Jun 2014 00:04:55 +0400
Message-ID: <CAOJe8K1TgTDX5=LdE9r6c0ami7TRa7zr0hL_uu6YpiWrsePAgQ@mail.gmail.com>
Subject: Re: kmemleak: Unable to handle kernel paging request
From: Denis Kirjanov <kda@linux-powerpc.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 6/11/14, Catalin Marinas <catalin.marinas@arm.com> wrote:
> On Wed, Jun 11, 2014 at 04:13:07PM +0400, Denis Kirjanov wrote:
>> I got a trace while running 3.15.0-08556-gdfb9454:
>>
>> [  104.534026] Unable to handle kernel paging request for data at
>> address 0xc00000007f000000
>
> Were there any kmemleak messages prior to this, like "kmemleak
> disabled"? There could be a race when kmemleak is disabled because of
> some fatal (for kmemleak) error while the scanning is taking place
> (which needs some more thinking to fix properly).

No. I checked for the similar problem and didn't find anything relevant.
I'll try to bisect it.

> Thanks.
>
> --
> Catalin
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
