Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id B113D6B0069
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 23:49:44 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id x192so303442339itb.3
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 20:49:44 -0700 (PDT)
Received: from mail-oi0-x229.google.com (mail-oi0-x229.google.com. [2607:f8b0:4003:c06::229])
        by mx.google.com with ESMTPS id m30si5760662oik.179.2016.09.12.20.49.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 20:49:44 -0700 (PDT)
Received: by mail-oi0-x229.google.com with SMTP id q188so242002246oia.3
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 20:49:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160913121645.652e6512@roar.ozlabs.ibm.com>
References: <147361509579.17004.5258725187329709824.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20160912133536.1bdb57a9@roar.ozlabs.ibm.com> <CAPcyv4hS7i1DApKPDB5PkfBNZVbk321FgP94kUDjmuyGXDidZg@mail.gmail.com>
 <20160913121645.652e6512@roar.ozlabs.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 12 Sep 2016 20:49:43 -0700
Message-ID: <CAPcyv4hSs2M3LYscsepYat+FN9e3aUxSY3kGMFD6M9-9BCR5HQ@mail.gmail.com>
Subject: Re: [RFC PATCH 1/2] mm, mincore2(): retrieve dax and tlb-size
 attributes of an address range
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Linux MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-api@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-arch@vger.kernel.org

On Mon, Sep 12, 2016 at 7:16 PM, Nicholas Piggin <npiggin@gmail.com> wrote:
> On Mon, 12 Sep 2016 10:29:17 -0700
[..]
>> Certainly one of the new request flags can indicate that the vector is
>> made up of larger entries.
>
> Hmm. Changing prototype depending on flags. I thought I was having
> a nightmare about ioctls for a minute there :)

Heh :)

> In general, is this what we want for a new API? Should we be thinking
> about an extent API?

This probably fits better with the use cases I know that want to
consume this information, something like fiemap (mextmap, maybe?) for
memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
