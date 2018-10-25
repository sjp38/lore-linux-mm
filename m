Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4406B0007
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 20:26:03 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j9-v6so3010423pfn.20
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 17:26:03 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 1-v6si6137918ply.390.2018.10.24.17.26.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 17:26:02 -0700 (PDT)
Subject: Re: [PATCH 03/17] prmem: vmalloc support for dynamic allocation
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
 <20181023213504.28905-4-igor.stoppa@huawei.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <489bf780-7dd2-2feb-8456-25ad5beeb3e4@intel.com>
Date: Wed, 24 Oct 2018 17:26:00 -0700
MIME-Version: 1.0
In-Reply-To: <20181023213504.28905-4-igor.stoppa@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org
Cc: igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Chintan Pandya <cpandya@codeaurora.org>, Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/23/18 2:34 PM, Igor Stoppa wrote:
> +#define VM_PMALLOC		0x00000100	/* pmalloc area - see docs */
> +#define VM_PMALLOC_WR		0x00000200	/* pmalloc write rare area */
> +#define VM_PMALLOC_PROTECTED	0x00000400	/* pmalloc protected area */

Please introduce things as you use them.  It's impossible to review a
patch that just says "see docs" that doesn't contain any docs. :)
