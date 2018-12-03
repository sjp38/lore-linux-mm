Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id C8FF96B6858
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 04:26:05 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id f5-v6so3441734ljj.17
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 01:26:05 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r10-v6sor7203325lji.40.2018.12.03.01.26.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 01:26:03 -0800 (PST)
Date: Mon, 3 Dec 2018 12:26:01 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 1/3] x86/mm: Move LDT remap out of KASLR region on
 5-level paging
Message-ID: <20181203092601.h7fuhvbmgdbfgqcd@kshutemo-mobl1>
References: <20181026122856.66224-1-kirill.shutemov@linux.intel.com>
 <20181026122856.66224-2-kirill.shutemov@linux.intel.com>
 <20181110122905.GA2653@MiWiFi-R3L-srv>
 <20181123155831.ewkrq4r27rne75mz@kshutemo-mobl1>
 <20181203030100.GA22521@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181203030100.GA22521@MiWiFi-R3L-srv>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, boris.ostrovsky@oracle.com, jgross@suse.com, willy@infradead.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 03, 2018 at 11:01:00AM +0800, Baoquan He wrote:
> It looks do-able, not sure if the test case is complicated or not, if
> not hard, I can have a try. And I have some internal bugs, can focus on
> this later. I saw you posted another patchset to fix xen issue, it may
> not be needed any more if we take this way?

Well, it depends on what is the first in the KALSR group. The fix will not
be needed if direct mapping comes the first.

But I would rather go with the patch anyway. The hypervisor hole is part
of ABI and we should not calculate it based on other movable entity
(direct mapping, LDT remap, whatever). It's too fragile.

-- 
 Kirill A. Shutemov
