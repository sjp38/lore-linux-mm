Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id A61C8280262
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 06:49:56 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id w70so2066006oie.15
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 03:49:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s143si1433801ois.91.2018.01.05.03.49.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jan 2018 03:49:55 -0800 (PST)
Date: Fri, 5 Jan 2018 12:49:50 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 05/23] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
Message-ID: <20180105114950.GA26807@redhat.com>
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
 <20171123003447.1DB395E3@viggo.jf.intel.com>
 <e80ac5b1-c562-fc60-ee84-30a3a40bde60@huawei.com>
 <93776eb2-b6d4-679a-280c-8ba558a69c34@linux.intel.com>
 <bda85c5e-d2be-f4ac-e2b4-4ef01d5a01a5@huawei.com>
 <20a54a5f-f4e5-2126-fb73-6a995d13d52d@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20a54a5f-f4e5-2126-fb73-6a995d13d52d@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

Hi Yisheng and Dave,

On Thu, Jan 04, 2018 at 10:29:53PM -0800, Dave Hansen wrote:
> On 01/04/2018 10:16 PM, Yisheng Xie wrote:
> > BTW, we have just reported a bug caused by kaiser[1], which looks like
> > caused by SMEP. Could you please help to have a look?
> > 
> > [1] https://lkml.org/lkml/2018/1/5/3
> 
> Please report that to your kernel vendor.  Your EFI page tables have the
> NX bit set on the low addresses.  There have been a bunch of iterations
> of this, but you need to make sure that the EFI kernel mappings don't
> get _PAGE_NX set on them.  Look at what __pti_set_user_pgd() does in
> mainline.

Yisheng could you file a report on the vendor bz?

>From my part of course I'm fine to discuss it here, but it's not fair
to use lkml bandwidth for this, sorry for the noise.

The vast majority of the hardware boots fine and isn't running into
this. This is the first time I hear about this, sorry about that.

I fixed it with the upstream solution, greatly appreciated the pointer
Dave. I don't have hardware to verify it though so we've to follow up
on bz.

Thanks,
Andrea
