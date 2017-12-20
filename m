Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE6C6B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 19:12:37 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id b26so14385381qtb.18
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 16:12:37 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id n67si8626433qkn.262.2017.12.20.16.12.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Dec 2017 16:12:36 -0800 (PST)
Message-ID: <1513810153.2743.25.camel@kernel.crashing.org>
Subject: Re: [PATCH v9 29/51] mm/mprotect, powerpc/mm/pkeys, x86/mm/pkeys:
 Add sysfs interface
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 21 Dec 2017 09:49:13 +1100
In-Reply-To: <20171220175022.GB5619@ram.oc3035372033.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
	 <1509958663-18737-30-git-send-email-linuxram@us.ibm.com>
	 <bbc5593e-31ec-183a-01a5-1a253dc0c275@intel.com>
	 <20171218221850.GD5461@ram.oc3035372033.ibm.com>
	 <e7971d03-6ad1-40d5-9b79-f01242db5293@intel.com>
	 <1513719296.2743.12.camel@kernel.crashing.org>
	 <20171220175022.GB5619@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com

On Wed, 2017-12-20 at 09:50 -0800, Ram Pai wrote:
> The argument against this patch is --  it should not be baked into
> the ABI as yet, since we do not have clarity on what applications need.
> 
> As it stands today the only way to figure out the information from
> userspace is by probing the kernel through calls to sys_pkey_alloc().
> 
> AT_HWCAP can be used, but that will certainly not be capable of
> providing all the information that userspace might expect.
> 
> Your thoughts?

Well, there's one well known application wanting that whole keys
business, so why not ask them what works for them ?

In the meantime, that shouldn't block the rest of the patches.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
