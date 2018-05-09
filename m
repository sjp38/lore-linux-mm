Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6D5C36B0532
	for <linux-mm@kvack.org>; Wed,  9 May 2018 12:08:28 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x23so18952975pfm.7
        for <linux-mm@kvack.org>; Wed, 09 May 2018 09:08:28 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d30-v6sor10233434pld.59.2018.05.09.09.08.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 May 2018 09:08:27 -0700 (PDT)
Subject: Re: [RFC][PATCH 00/13] Provide saturating helpers for allocation
References: <20180509004229.36341-1-keescook@chromium.org>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <4baffc55-510e-96d3-3487-5ea09f993a0c@redhat.com>
Date: Wed, 9 May 2018 09:08:24 -0700
MIME-Version: 1.0
In-Reply-To: <20180509004229.36341-1-keescook@chromium.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Matthew Wilcox <mawilcox@microsoft.com>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On 05/08/2018 05:42 PM, Kees Cook wrote:
> This is a stab at providing three new helpers for allocation size
> calculation:
> 
> struct_size(), array_size(), and array3_size().
> 
> These are implemented on top of Rasmus's overflow checking functions,
> and the last 8 patches are all treewide conversions of open-coded
> multiplications into the various combinations of the helper functions.
> 
> -Kees
> 
> 
Obvious question (that might indicate this deserves documentation?)

What's the difference between

kmalloc_array(cnt, sizeof(struct blah), GFP_KERNEL);

and

kmalloc(array_size(cnt, struct blah), GFP_KERNEL);


and when would you use one over the other?

Thanks,
Laura
