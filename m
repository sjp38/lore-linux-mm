Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0785E6B053E
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 13:33:12 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id p10so6250252pgr.6
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 10:33:11 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id t22si378071plj.269.2017.07.11.10.33.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 10:33:11 -0700 (PDT)
Subject: Re: [RFC v5 36/38] selftest: PowerPC specific test updates to memory
 protection keys
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <1499289735-14220-37-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <c0e2eab4-a724-5155-4ae9-03b37e4b9f54@intel.com>
Date: Tue, 11 Jul 2017 10:33:09 -0700
MIME-Version: 1.0
In-Reply-To: <1499289735-14220-37-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On 07/05/2017 02:22 PM, Ram Pai wrote:
> Abstracted out the arch specific code into the header file, and
> added powerpc specific changes.
> 
> a) added 4k-backed hpte, memory allocator, powerpc specific.
> b) added three test case where the key is associated after the page is
> 	accessed/allocated/mapped.
> c) cleaned up the code to make checkpatch.pl happy

There's a *lot* of churn here.  If it breaks, I'm going to have a heck
of a time figuring out which hunk broke.  Is there any way to break this
up into a series of things that we have a chance at bisecting?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
