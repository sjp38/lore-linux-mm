Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id BFF4C6B0297
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 18:02:04 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id h19so5632996wmi.10
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 15:02:04 -0700 (PDT)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id h6si27617227wrc.69.2017.04.24.15.02.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 15:02:03 -0700 (PDT)
Received: by mail-wm0-x22e.google.com with SMTP id r190so10950578wme.1
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 15:02:03 -0700 (PDT)
Date: Tue, 25 Apr 2017 01:01:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Question on the five-level page table support patches
Message-ID: <20170424220158.z67cir7sjfyn4wdt@node.shutemov.name>
References: <030ea57b-5f6c-13d8-02f7-b245a754a87d@physik.fu-berlin.de>
 <20170424161959.c5ba2nhnxyy57wxe@node.shutemov.name>
 <fdc80e3c-6909-cf39-fe0b-6f1c012571e4@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fdc80e3c-6909-cf39-fe0b-6f1c012571e4@physik.fu-berlin.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Mon, Apr 24, 2017 at 10:37:40PM +0200, John Paul Adrian Glaubitz wrote:
> On 04/24/2017 06:19 PM, Kirill A. Shutemov wrote:
> > In proposed implementation, we also use hint address, but in different
> > way: by default, if hint address is NULL, kernel would not create mappings
> > above 47-bits, preserving compatibility.
> 
> Ooooh, that would solve a lot of problems actually if it were to be available
> on all architectures. On SPARC, the situation is really annoying and I have
> been discussing a solution with the Qt developers and they suggested a
> similar approach, just one that would also apply to brk() [1].
> 
> > If an application wants to have access to larger address space, it has to
> > specify hint addess above 47-bits.
> > 
> > See details here:
> > 
> > http://lkml.kernel.org/r/20170420162147.86517-10-kirill.shutemov@linux.intel.com
> 
> Thanks. I'll have a read. Although from your message I'm reading out that
> this particular proposal got rejected.

No. I just wasn't applied yet, so situation may change.

> Would be really nice to able to have a canonical solution for this issue,
> it's been biting us on SPARC for quite a while now due to the fact that
> virtual address space has been 52 bits on SPARC for a while now.

Power folks are going to implement similar approach. I don't see why Sparc
can't go the same route.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
