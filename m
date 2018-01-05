Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 28C2F6B049D
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 01:29:56 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id o9so1963649pgv.3
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 22:29:56 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id i75si178762pgc.392.2018.01.04.22.29.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 22:29:55 -0800 (PST)
Subject: Re: [PATCH 05/23] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
 <20171123003447.1DB395E3@viggo.jf.intel.com>
 <e80ac5b1-c562-fc60-ee84-30a3a40bde60@huawei.com>
 <93776eb2-b6d4-679a-280c-8ba558a69c34@linux.intel.com>
 <bda85c5e-d2be-f4ac-e2b4-4ef01d5a01a5@huawei.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <20a54a5f-f4e5-2126-fb73-6a995d13d52d@linux.intel.com>
Date: Thu, 4 Jan 2018 22:29:53 -0800
MIME-Version: 1.0
In-Reply-To: <bda85c5e-d2be-f4ac-e2b4-4ef01d5a01a5@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On 01/04/2018 10:16 PM, Yisheng Xie wrote:
> BTW, we have just reported a bug caused by kaiser[1], which looks like
> caused by SMEP. Could you please help to have a look?
> 
> [1] https://lkml.org/lkml/2018/1/5/3

Please report that to your kernel vendor.  Your EFI page tables have the
NX bit set on the low addresses.  There have been a bunch of iterations
of this, but you need to make sure that the EFI kernel mappings don't
get _PAGE_NX set on them.  Look at what __pti_set_user_pgd() does in
mainline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
