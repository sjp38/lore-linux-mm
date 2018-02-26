Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3786B000A
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 16:16:20 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id a26so4207200pgn.18
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 13:16:20 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id 33-v6si7402250plu.426.2018.02.26.13.16.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 13:16:19 -0800 (PST)
Subject: Re: [PATCH v12 3/3] mm, x86, powerpc: display pkey in smaps only if
 arch supports pkeys
References: <1519257138-23797-1-git-send-email-linuxram@us.ibm.com>
 <1519257138-23797-4-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <2a7737cf-a5ba-c814-fdc7-45b5cdd47376@intel.com>
Date: Mon, 26 Feb 2018 13:16:16 -0800
MIME-Version: 1.0
In-Reply-To: <1519257138-23797-4-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com

On 02/21/2018 03:52 PM, Ram Pai wrote:
> Currently the  architecture  specific code is expected to
> display  the  protection  keys  in  smap  for a given vma.
> This can lead to redundant code and possibly to divergent
> formats in which the key gets displayed.
> 
> This  patch  changes  the implementation. It displays the
> pkey only if the architecture support pkeys, i.e
> arch_pkeys_enabled() returns true.  This patch
> provides x86 implementation for arch_pkeys_enabled().
> 
> x86 arch_show_smap() function is not needed anymore.
> Deleting it.

This looks fine to me.  Thanks for doing these, Ram.

Reviewed-by: Dave Hansen <dave.hansen@intel.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
