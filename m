Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0CA4A6B0007
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 14:30:33 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id a5-v6so3239304plp.0
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 11:30:33 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id v4si13286953pgt.83.2018.03.08.11.30.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 11:30:32 -0800 (PST)
Subject: Re: mm, x86, powerpc: pkey semantics for key-0 ?
References: <1519257138-23797-1-git-send-email-linuxram@us.ibm.com>
 <1519257138-23797-4-git-send-email-linuxram@us.ibm.com>
 <2a7737cf-a5ba-c814-fdc7-45b5cdd47376@intel.com>
 <20180308182517.GO1060@ram.oc3035372033.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <1bfaa8c0-cd9c-b590-9930-e9584dfb928d@intel.com>
Date: Thu, 8 Mar 2018 11:30:29 -0800
MIME-Version: 1.0
In-Reply-To: <20180308182517.GO1060@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com, Ulrich.Weigand@de.ibm.com

On 03/08/2018 10:25 AM, Ram Pai wrote:
> Is there a reason why the default key; key-0, is not allowed to be
> explicitly associated with pages using pkey_mprotect()?

No, it's a bug if it is not permitted.  I have a vague recollection of
knowing about this and having a patch.
