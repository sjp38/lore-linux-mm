Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 913D46B03B4
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 14:12:37 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id q185-v6so2816202ljb.14
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 11:12:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j2-v6sor2617225lfg.29.2018.10.29.11.12.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Oct 2018 11:12:35 -0700 (PDT)
Subject: Re: [PATCH 05/17] prmem: shorthands for write rare on common types
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
 <20181023213504.28905-6-igor.stoppa@huawei.com>
 <fbb38802-3dc3-4890-c981-724b9096a6be@intel.com>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <aa6d9911-c5f8-d759-a117-810d59763467@gmail.com>
Date: Mon, 29 Oct 2018 20:12:32 +0200
MIME-Version: 1.0
In-Reply-To: <fbb38802-3dc3-4890-c981-724b9096a6be@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org
Cc: igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 25/10/2018 01:28, Dave Hansen wrote:
> On 10/23/18 2:34 PM, Igor Stoppa wrote:
>> Wrappers around the basic write rare functionality, addressing several
>> common data types found in the kernel, allowing to specify the new
>> values through immediates, like constants and defines.
> 
> I have to wonder whether this is the right way, or whether a
> size-agnostic function like put_user() is the right way.  put_user() is
> certainly easier to use.

I definitely did not like it either.
But it was the best that came to my mind ...
The main purpose of this code was to show what I wanted to do.
Once more, thanks for pointing out a better way to do it.

--
igor
