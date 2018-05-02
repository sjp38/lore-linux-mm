Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D7D256B0003
	for <linux-mm@kvack.org>; Wed,  2 May 2018 18:32:45 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w7so10874264pfd.9
        for <linux-mm@kvack.org>; Wed, 02 May 2018 15:32:45 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id i89si3307785pfd.117.2018.05.02.15.32.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 15:32:44 -0700 (PDT)
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change
 signal semantics
References: <20180502132751.05B9F401F3041@oldenburg.str.redhat.com>
 <248faadb-e484-806f-1485-c34a72a9ca0b@intel.com>
 <822a28c9-5405-68c2-11bf-0c282887466d@redhat.com>
 <57459C6F-C8BA-4E2D-99BA-64F35C11FC05@amacapital.net>
 <6286ba0a-7e09-b4ec-e31f-bd091f5940ff@redhat.com>
 <CALCETrVrm6yGiv6_z7RqdeB-324RoeMmjpf1EHsrGOh+iKb7+A@mail.gmail.com>
 <b2df1386-9df9-2db8-0a25-51bf5ff63592@redhat.com>
 <CALCETrW_Dt-HoG4keFJd8DSD=tvyR+bBCFrBDYdym4GQbfng4A@mail.gmail.com>
 <a37b7deb-7f5a-3dfa-f360-956cab8a813a@intel.com>
 <CALCETrUM7wWZh55gaLiAoPqtxLLUJ4QC8r8zj62E9avJ6ZVu0w@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <f9f7edc5-6426-91aa-f279-2f9f4671957a@intel.com>
Date: Wed, 2 May 2018 15:32:42 -0700
MIME-Version: 1.0
In-Reply-To: <CALCETrUM7wWZh55gaLiAoPqtxLLUJ4QC8r8zj62E9avJ6ZVu0w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Florian Weimer <fweimer@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-x86_64@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, linuxram@us.ibm.com

On 05/02/2018 03:22 PM, Andy Lutomirski wrote:
> That library wants other threads, signal handlers, and, in general, the
> whole rest of the process to be restricted, and that library doesn't want
> race conditions.  The problem here is that, to get this right, we either
> need the PKRU modifications to be syscalls or to take locks, and the lock
> approach is going to be fairly gross.

I totally get the idea that a RDPKRU/WRPKRU is non-atomic and that it
can't be mixed with asynchronous WRPKRU's in that thread.

But, where do those come from in this scenario?  I'm not getting the
secondary mechanism is that *makes* them unsafe.
