Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9E3466B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 14:17:40 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 91-v6so7416004pla.18
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 11:17:40 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id a3si540664pgt.644.2018.04.09.11.17.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 11:17:39 -0700 (PDT)
Subject: Re: [PATCH 00/11] [v5] Use global pages with PTI
References: <20180406205501.24A1A4E7@viggo.jf.intel.com>
 <c96373d0-c16a-4463-147c-8624ad90af61@amd.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <b9802f89-93b3-b535-742c-f84e9f5be832@linux.intel.com>
Date: Mon, 9 Apr 2018 11:17:37 -0700
MIME-Version: 1.0
In-Reply-To: <c96373d0-c16a-4463-147c-8624ad90af61@amd.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, aarcange@redhat.com, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org, namit@vmware.com

On 04/09/2018 11:04 AM, Tom Lendacky wrote:
> On 4/6/2018 3:55 PM, Dave Hansen wrote:
>> Changes from v4
>>  * Fix compile error reported by Tom Lendacky
> This built with CONFIG_RANDOMIZE_BASE=y, but failed to boot successfully.
> I think you're missing the initialization of __default_kernel_pte_mask in
> kaslr.c.

This should be simple to fix (just add a -1 instead of 0), but let me
double-check and actually boot the fix.
