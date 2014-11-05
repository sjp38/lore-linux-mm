Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id A7B486B00A7
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 10:21:15 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id ex7so2307043wid.16
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 07:21:15 -0800 (PST)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com. [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id es4si17185740wib.5.2014.11.05.07.21.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 07:21:14 -0800 (PST)
Received: by mail-wi0-f170.google.com with SMTP id r20so325927wiv.5
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 07:21:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5457C6EA.3080809@intel.com>
References: <1414771317-5721-1-git-send-email-standby24x7@gmail.com>
	<5457C6EA.3080809@intel.com>
Date: Thu, 6 Nov 2014 00:21:14 +0900
Message-ID: <CALLJCT0fofgUaswpzt1iBqGS1u+fR8L=umwGpV=RG0SvO9TOJA@mail.gmail.com>
Subject: Re: [PATCH] Documentation: vm: Add 1GB large page support information
From: Masanari Iida <standby24x7@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Jonathan Corbet <corbet@lwn.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, lcapitulino@redhat.com

Luiz, Dave,
Thanks for comments.

I understand that there are some exception cases which doesn't support 1G
large pages on newer CPUs.
I like Dave's example, at the same time I would like to add "pdpe1gb flag" in
the document.

For example, x86 CPUs normally support 4K and 2M (1G if pdpe1gb flag exist).

Masanari

On Tue, Nov 4, 2014 at 3:18 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 10/31/2014 09:01 AM, Masanari Iida wrote:
>> --- a/Documentation/vm/hugetlbpage.txt
>> +++ b/Documentation/vm/hugetlbpage.txt
>> @@ -2,7 +2,8 @@
>>  The intent of this file is to give a brief summary of hugetlbpage support in
>>  the Linux kernel.  This support is built on top of multiple page size support
>>  that is provided by most modern architectures.  For example, i386
>> -architecture supports 4K and 4M (2M in PAE mode) page sizes, ia64
>> +architecture supports 4K and 4M (2M in PAE mode) page sizes, x86_64
>> +architecture supports 4K, 2M and 1G (SandyBridge or later) page sizes. ia64
>>  architecture supports multiple page sizes 4K, 8K, 64K, 256K, 1M, 4M, 16M,
>>  256M and ppc64 supports 4K and 16M.  A TLB is a cache of virtual-to-physical
>>  translations.  Typically this is a very scarce resource on processor.
>
> I wouldn't mention SandyBridge.  Not all x86 CPUs are Intel. :)
>
> Also, what of the Intel CPUs like the Xeon Phi or the Atom cores?  I
> have an IvyBridge (>= Sandybridge) mobile CPU in this laptop which does
> not support 1G pages.
>
> I would axe the i386-specific reference and just say something generic like:
>
>        For example, x86 CPUs normally support 4K and 2M (1G sometimes).
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
