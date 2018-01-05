Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9555D6B0506
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 14:18:31 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id q12so3583615plk.16
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 11:18:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x81si4463093pff.17.2018.01.05.11.18.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Jan 2018 11:18:30 -0800 (PST)
Date: Fri, 5 Jan 2018 20:18:28 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH 05/23] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
In-Reply-To: <nycvar.YFH.7.76.1801052014050.11852@cbobk.fhfr.pm>
Message-ID: <nycvar.YFH.7.76.1801052017310.11852@cbobk.fhfr.pm>
References: <20171123003438.48A0EEDE@viggo.jf.intel.com> <20171123003447.1DB395E3@viggo.jf.intel.com> <e80ac5b1-c562-fc60-ee84-30a3a40bde60@huawei.com> <93776eb2-b6d4-679a-280c-8ba558a69c34@linux.intel.com> <bda85c5e-d2be-f4ac-e2b4-4ef01d5a01a5@huawei.com>
 <20a54a5f-f4e5-2126-fb73-6a995d13d52d@linux.intel.com> <alpine.LRH.2.00.1801051909160.27010@gjva.wvxbf.pm> <282e2a56-ded1-6eb9-5ecb-22858c424bd7@linux.intel.com> <nycvar.YFH.7.76.1801052014050.11852@cbobk.fhfr.pm>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, keescook@google.com, hughd@google.com, x86@kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On Fri, 5 Jan 2018, Jiri Kosina wrote:

> That's because pgd_populate() uses _PAGE_TABLE and not _KERNPG_TABLE for 
> reasons that are behind me.

[ oh and BTW I find the fact that we have populate_pgd() and 
pgd_populate(), which do something *completely* different quite 
entertaining ]

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
