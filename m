Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 25B7F6B0027
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 15:37:01 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j8so7168035pfh.13
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 12:37:01 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id a5-v6si8885790plh.450.2018.03.23.12.37.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 12:37:00 -0700 (PDT)
Subject: Re: [PATCH 09/11] x86/pti: enable global pages for shared areas
References: <20180323174447.55F35636@viggo.jf.intel.com>
 <20180323174500.64BD3D36@viggo.jf.intel.com>
 <7B08037D-1682-406D-90F1-C2B5B1899F7F@vmware.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <4f97f448-307f-1095-84cc-1b7444eb78a8@linux.intel.com>
Date: Fri, 23 Mar 2018 12:36:58 -0700
MIME-Version: 1.0
In-Reply-To: <7B08037D-1682-406D-90F1-C2B5B1899F7F@vmware.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "aarcange@redhat.com" <aarcange@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "keescook@google.com" <keescook@google.com>, "hughd@google.com" <hughd@google.com>, "jgross@suse.com" <jgross@suse.com>, "x86@kernel.org" <x86@kernel.org>

On 03/23/2018 12:12 PM, Nadav Amit wrote:
>> 		/*
>> +		 * Setting 'target_pmd' below creates a mapping in both
>> +		 * the user and kernel page tables.  It is effectively
>> +		 * global, so set it as global in both copies.
>> +		 */
>> +		*pmd = pmd_set_flags(*pmd, _PAGE_GLOBAL);
> if (boot_cpu_has(X86_FEATURE_PGE)) ?

Good catch.  I'll update that.
