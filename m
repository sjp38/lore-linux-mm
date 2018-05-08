Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 233356B0008
	for <linux-mm@kvack.org>; Tue,  8 May 2018 10:39:21 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id x205-v6so18631981pgx.19
        for <linux-mm@kvack.org>; Tue, 08 May 2018 07:39:21 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id g15-v6si1566449pgp.217.2018.05.08.07.39.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 08 May 2018 07:39:20 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v13 0/3] mm, x86, powerpc: Enhancements to Memory Protection Keys.
In-Reply-To: <1525471183-21277-1-git-send-email-linuxram@us.ibm.com>
References: <1525471183-21277-1-git-send-email-linuxram@us.ibm.com>
Date: Wed, 09 May 2018 00:39:14 +1000
Message-ID: <8736z21ab1.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, mingo@redhat.com, akpm@linux-foundation.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de

Ram Pai <linuxram@us.ibm.com> writes:

> This patch series provides arch-neutral enhancements to
> enable memory-keys on new architecutes, and the corresponding
> changes in x86 and powerpc specific code to support that.
>
> a) Provides ability to support upto 32 keys.  PowerPC
>         can handle 32 keys and hence needs this.
>
> b) Arch-neutral code; and not the arch-specific code,
>    determines the format of the string, that displays the key
>    for each vma in smaps.
>
> History:
> -------
> version 14:

This doesn't match the patch subjects, which is a little confusing :)

> 	(1) made VM_PKEY_BIT4 unusable on x86, #defined it to 0
> 		-- comment by Dave Hansen
> 	(2) due to some reason this patch series continue to
> 	      break some or the other build. The last series
> 	      passed everything but created a merge
> 	      conflict followed by build failure for
> 	      Michael Ellermen. :(

I have a fix, it involved some cleanup of headers prior to the smaps
change.

Will post it.

cheers
