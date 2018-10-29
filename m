Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A6636B03AB
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 14:07:33 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id d3-v6so3432675ljc.11
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 11:07:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j10-v6sor8489381lji.38.2018.10.29.11.07.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Oct 2018 11:07:31 -0700 (PDT)
Subject: Re: [PATCH 03/17] prmem: vmalloc support for dynamic allocation
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
 <20181023213504.28905-4-igor.stoppa@huawei.com>
 <489bf780-7dd2-2feb-8456-25ad5beeb3e4@intel.com>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <624caa9a-e591-a1f4-40d1-49db10a91f03@gmail.com>
Date: Mon, 29 Oct 2018 20:07:23 +0200
MIME-Version: 1.0
In-Reply-To: <489bf780-7dd2-2feb-8456-25ad5beeb3e4@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org
Cc: igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Chintan Pandya <cpandya@codeaurora.org>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 25/10/2018 01:26, Dave Hansen wrote:
> On 10/23/18 2:34 PM, Igor Stoppa wrote:
>> +#define VM_PMALLOC		0x00000100	/* pmalloc area - see docs */
>> +#define VM_PMALLOC_WR		0x00000200	/* pmalloc write rare area */
>> +#define VM_PMALLOC_PROTECTED	0x00000400	/* pmalloc protected area */
> 
> Please introduce things as you use them.  It's impossible to review a
> patch that just says "see docs" that doesn't contain any docs. :)

Yes, otoh it's a big pain in the neck to keep the docs split into 
smaller patches interleaved with the code, at least while the code is 
still in a flux.

And since the docs refer to the sources, for the automated documentation 
of the API, I cannot just put the documentation at the beginning of the 
patchset.

Can I keep the docs as they are, for now, till the code is more stable?

--
igor
