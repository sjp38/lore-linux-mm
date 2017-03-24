Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9164D6B0343
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 05:03:44 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u52so6454227wrc.7
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 02:03:44 -0700 (PDT)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id e27si2226681wrc.122.2017.03.24.02.03.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 02:03:09 -0700 (PDT)
Received: by mail-wm0-x22b.google.com with SMTP id u132so7614348wmg.0
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 02:03:09 -0700 (PDT)
Date: Fri, 24 Mar 2017 12:03:07 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 26/26] x86/mm: allow to have userspace mappings above
 47-bits
Message-ID: <20170324090307.hcx57t6yr4wqv4uz@node.shutemov.name>
References: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
 <20170313055020.69655-27-kirill.shutemov@linux.intel.com>
 <87a88jg571.fsf@skywalker.in.ibm.com>
 <20170317175714.3bvpdylaaudf4ig2@node.shutemov.name>
 <877f3lfzdo.fsf@skywalker.in.ibm.com>
 <878to1sl1v.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <878to1sl1v.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Mar 19, 2017 at 02:25:08PM +0530, Aneesh Kumar K.V wrote:
> >>> So if I have done a successful mmap which returned > 128TB what should a
> >>> following mmap(0,...) return ? Should that now search the *full* address
> >>> space or below 128TB ?
> >>
> >> No, I don't think so. And this implementation doesn't do this.
> >>
> >> It's safer this way: if an library can't handle high addresses, it's
> >> better not to switch it automagically to full address space if other part
> >> of the process requested high address.
> >>
> >
> > What is the epectation when the hint addr is below 128TB but addr + len >
> > 128TB ? Should such mmap request fail ?
> 
> Considering that we have stack at the top (around 128TB) we may not be
> able to get a free area for such a request. But I guess the idea here is
> that if hint address is below 128TB, we behave as though our TASK_SIZE
> is 128TB ? Is that correct ?

Right.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
