Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 40AEC6B000A
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 20:28:14 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id w64-v6so5265775pfk.2
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 17:28:14 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id l1-v6si6142298pgm.288.2018.10.24.17.28.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 17:28:13 -0700 (PDT)
Subject: Re: [PATCH 05/17] prmem: shorthands for write rare on common types
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
 <20181023213504.28905-6-igor.stoppa@huawei.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <fbb38802-3dc3-4890-c981-724b9096a6be@intel.com>
Date: Wed, 24 Oct 2018 17:28:12 -0700
MIME-Version: 1.0
In-Reply-To: <20181023213504.28905-6-igor.stoppa@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org
Cc: igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/23/18 2:34 PM, Igor Stoppa wrote:
> Wrappers around the basic write rare functionality, addressing several
> common data types found in the kernel, allowing to specify the new
> values through immediates, like constants and defines.

I have to wonder whether this is the right way, or whether a
size-agnostic function like put_user() is the right way.  put_user() is
certainly easier to use.
