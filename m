Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E9BBB6B0007
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 17:40:38 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id a5-v6so5138368plp.0
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 14:40:38 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id q13si1373129pgt.303.2018.03.09.14.40.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 14:40:37 -0800 (PST)
Subject: Re: [PATCH] x86, powerpc : pkey-mprotect must allow pkey-0
References: <1520583161-11741-1-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <60886e4a-59d4-541a-a6af-d4504e6719ad@intel.com>
Date: Fri, 9 Mar 2018 14:40:32 -0800
MIME-Version: 1.0
In-Reply-To: <1520583161-11741-1-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com, Ulrich.Weigand@de.ibm.com

On 03/09/2018 12:12 AM, Ram Pai wrote:
> Once an address range is associated with an allocated pkey, it cannot be
> reverted back to key-0. There is no valid reason for the above behavior.  On
> the contrary applications need the ability to do so.

Why don't we just set pkey 0 to be allocated in the allocation bitmap by
default?

We *could* also just not let it be special and let it be freed.  An app
could theoretically be careful and make sure nothing is using it.
