Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3FBA46B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 13:57:24 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id w22so11282437pge.10
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 10:57:24 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id n18si436524pgc.416.2017.12.18.10.54.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 10:54:32 -0800 (PST)
Subject: Re: [PATCH v9 29/51] mm/mprotect, powerpc/mm/pkeys, x86/mm/pkeys: Add
 sysfs interface
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
 <1509958663-18737-30-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <bbc5593e-31ec-183a-01a5-1a253dc0c275@intel.com>
Date: Mon, 18 Dec 2017 10:54:26 -0800
MIME-Version: 1.0
In-Reply-To: <1509958663-18737-30-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com

On 11/06/2017 12:57 AM, Ram Pai wrote:
> Expose useful information for programs using memory protection keys.
> Provide implementation for powerpc and x86.
> 
> On a powerpc system with pkeys support, here is what is shown:
> 
> $ head /sys/kernel/mm/protection_keys/*
> ==> /sys/kernel/mm/protection_keys/disable_access_supported <==
> true

This is cute, but I don't think it should be part of the ABI.  Put it in
debugfs if you want it for cute tests.  The stuff that this tells you
can and should come from pkey_alloc() for the ABI.

http://man7.org/linux/man-pages/man7/pkeys.7.html

>        Any application wanting to use protection keys needs to be able to
>        function without them.  They might be unavailable because the
>        hardware that the application runs on does not support them, the
>        kernel code does not contain support, the kernel support has been
>        disabled, or because the keys have all been allocated, perhaps by a
>        library the application is using.  It is recommended that
>        applications wanting to use protection keys should simply call
>        pkey_alloc(2) and test whether the call succeeds, instead of
>        attempting to detect support for the feature in any other way.

Do you really not have standard way on ppc to say whether hardware
features are supported by the kernel?  For instance, how do you know if
a given set of registers are known to and are being context-switched by
the kernel?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
