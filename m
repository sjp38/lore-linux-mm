Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 821906B0294
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 04:01:41 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id f32so2167507otc.13
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 01:01:41 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id 6si383157oth.345.2018.02.22.01.01.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 01:01:40 -0800 (PST)
Subject: Re: [PATCH 5/6] Pmalloc: self-test
References: <20180212165301.17933-1-igor.stoppa@huawei.com>
 <20180212165301.17933-6-igor.stoppa@huawei.com>
 <CAGXu5j+ZZkgLzsxcwAYgyu=A=11Fkeuj+F_8gCUAbXDmjWFdeg@mail.gmail.com>
 <bd11826b-f3c1-be03-895c-85c08a149045@huawei.com>
 <CAGXu5j+ivd0Ys++6hqCjkipx8RFKTAmWf+KbtxEwT3SECD5C6A@mail.gmail.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <cfe0dd48-2c72-cc4f-010b-a667648cad3b@huawei.com>
Date: Thu, 22 Feb 2018 11:01:09 +0200
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+ivd0Ys++6hqCjkipx8RFKTAmWf+KbtxEwT3SECD5C6A@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Matthew Wilcox <willy@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Christoph
 Lameter <cl@linux.com>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>



On 22/02/18 00:24, Kees Cook wrote:
> On Tue, Feb 20, 2018 at 8:40 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:

[...]

>> sorry for being dense ... are you proposing that I do something to
>> lkdtm_rodata.c ? An example would probably help me understand.
> 
> It would likely live in lkdtm_perms.c (or maybe lkdtm_heap.c). Namely,
> use the pmalloc API and then attempt to write to a read-only variable
> in the pmalloc region (to prove that the permission adjustment
> actually happened). Likely a good example is
> lkdtm_WRITE_RO_AFTER_INIT().


ok, thanks for the explanation, I will do it

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
