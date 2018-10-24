Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 774D56B000D
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 10:24:08 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id r24-v6so1917988ljr.18
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 07:24:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o5-v6sor1631670lfe.54.2018.10.24.07.24.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Oct 2018 07:24:06 -0700 (PDT)
Subject: Re: [PATCH 06/17] prmem: test cases for memory protection
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
 <20181023213504.28905-7-igor.stoppa@huawei.com>
 <a6c74bb1-bd0c-ed8a-1dd3-b04f2e3c78d4@infradead.org>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <00461c0a-a214-1984-5614-c7a4a2a7ff83@gmail.com>
Date: Wed, 24 Oct 2018 17:24:03 +0300
MIME-Version: 1.0
In-Reply-To: <a6c74bb1-bd0c-ed8a-1dd3-b04f2e3c78d4@infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org
Cc: igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

On 24/10/18 06:27, Randy Dunlap wrote:

> a. It seems backwards (or upside down) to have a test case select a feature (PRMEM)
> instead of depending on that feature.
> 
> b. Since PRMEM depends on MMU (in patch 04/17), the "select" here could try to
> enabled PRMEM even when MMU is not enabled.
> 
> Changing this to "depends on PRMEM" would solve both of these issues.

The weird dependency you pointed out is partially caused by the 
incompleteness of PRMEM.

What I have in mind is to have a fallback version of it for systems 
without MMU capable of write protection.
Possibly defaulting to kvmalloc.
In that case there would not be any need for a configuration option.

> c. Don't use "default n".  That is already the default.

ok

--
igor
