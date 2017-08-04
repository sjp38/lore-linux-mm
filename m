Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id ED604280396
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 15:25:18 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d5so26745996pfg.3
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 12:25:18 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id m6si1527285pln.457.2017.08.04.12.25.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Aug 2017 12:25:17 -0700 (PDT)
Subject: Re: [PATCH 1/2] x86,mpx: make mpx depend on x86-64 to free up VMA
 flag
References: <20170804190730.17858-1-riel@redhat.com>
 <20170804190730.17858-2-riel@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <543e85d4-d4a1-41a7-cfcf-6a88c0124998@intel.com>
Date: Fri, 4 Aug 2017 12:25:15 -0700
MIME-Version: 1.0
In-Reply-To: <20170804190730.17858-2-riel@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, fweimer@redhat.com, colm@allcosts.net, akpm@linux-foundation.org, rppt@linux.vnet.ibm.com, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org

On 08/04/2017 12:07 PM, riel@redhat.com wrote:
> MPX only seems to be available on 64 bit CPUs, starting with Skylake
> and Goldmont. Move VM_MPX into the 64 bit only portion of vma->vm_flags,
> in order to free up a VMA flag.

Makes me a little sad.  But, seems worth it.

Acked-by: Dave Hansen <dave.hansen@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
