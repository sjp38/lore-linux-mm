Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 060B4280265
	for <linux-mm@kvack.org>; Sat,  6 Jan 2018 02:51:41 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id q12so4571565plk.16
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 23:51:40 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id b60si5247308plc.309.2018.01.05.23.51.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jan 2018 23:51:40 -0800 (PST)
Subject: Re: [PATCH 05/23] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
 <20171123003447.1DB395E3@viggo.jf.intel.com>
 <e80ac5b1-c562-fc60-ee84-30a3a40bde60@huawei.com>
 <93776eb2-b6d4-679a-280c-8ba558a69c34@linux.intel.com>
 <bda85c5e-d2be-f4ac-e2b4-4ef01d5a01a5@huawei.com>
 <20a54a5f-f4e5-2126-fb73-6a995d13d52d@linux.intel.com>
 <alpine.LRH.2.00.1801051909160.27010@gjva.wvxbf.pm>
 <ac54449b-feeb-58d2-45e6-5ebb9784ed13@huawei.com>
 <332f4eab-8a3d-8b29-04f2-7c075f81b85b@linux.intel.com>
 <dcab663f-b090-7447-e43a-44cc8c4a8c8b@huawei.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <10ed0bc4-5f98-b771-5020-12838923b0ca@linux.intel.com>
Date: Fri, 5 Jan 2018 23:51:38 -0800
MIME-Version: 1.0
In-Reply-To: <dcab663f-b090-7447-e43a-44cc8c4a8c8b@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hanjun Guo <guohanjun@huawei.com>, Jiri Kosina <jikos@kernel.org>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, keescook@google.com, hughd@google.com, x86@kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On 01/05/2018 10:28 PM, Hanjun Guo wrote:
>> +
>>  	p4d = p4d_alloc(&tboot_mm, pgd, vaddr);
> Seems pgd will be re-set after p4d_alloc(), so should
> we put the code behind (or after pud_alloc())?

<sigh> Yes, it has to go below where the PGD actually gets set which is
after pud_alloc().  You can put it anywhere later in the function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
