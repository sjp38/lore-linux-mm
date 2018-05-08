Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id ED67B6B02B5
	for <linux-mm@kvack.org>; Tue,  8 May 2018 12:47:18 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id x32-v6so2112981pld.16
        for <linux-mm@kvack.org>; Tue, 08 May 2018 09:47:18 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id q192si17624008pfq.307.2018.05.08.09.47.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 09:47:18 -0700 (PDT)
Subject: Re: [PATCH 8/8] mm/pkeys, x86, powerpc: Display pkey in smaps if arch
 supports pkeys
References: <20180508145948.9492-1-mpe@ellerman.id.au>
 <20180508145948.9492-9-mpe@ellerman.id.au>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <cd58dbfe-55f9-bb9a-d907-0f92740a8c2e@intel.com>
Date: Tue, 8 May 2018 09:47:15 -0700
MIME-Version: 1.0
In-Reply-To: <20180508145948.9492-9-mpe@ellerman.id.au>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, linuxram@us.ibm.com
Cc: mingo@redhat.com, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On 05/08/2018 07:59 AM, Michael Ellerman wrote:
> Currently the architecture specific code is expected to display the
> protection keys in smap for a given vma. This can lead to redundant
> code and possibly to divergent formats in which the key gets
> displayed.
> 
> This patch changes the implementation. It displays the pkey only if
> the architecture support pkeys, i.e arch_pkeys_enabled() returns true.


For this, along with 6/8 and 7/8:

Reviewed-by: Dave Hansen <dave.hansen@intel.com>
