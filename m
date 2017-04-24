Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E3B866B02C4
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:03:35 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 194so11787762pfv.11
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 06:03:35 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id b1si18912530plc.191.2017.04.24.06.03.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 06:03:35 -0700 (PDT)
Date: Mon, 24 Apr 2017 06:03:11 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: Question on the five-level page table support patches
Message-ID: <20170424130311.GR4021@tassilo.jf.intel.com>
References: <030ea57b-5f6c-13d8-02f7-b245a754a87d@physik.fu-berlin.de>
 <CALCETrUcB7STNjVw=WBZdFfz_H1DKcLnj3HHtnGaHGQ1UY8Zrw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUcB7STNjVw=WBZdFfz_H1DKcLnj3HHtnGaHGQ1UY8Zrw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> Can you explain what the issue is?  What used to work on Linux and
> doesn't any more?  The man page is quite clear:

In old Linux hint was a search hint, so if there isn't a hole
at the hinted area it will search starting from there for a hole
instead of giving up immediately.

Now it just gives up, which means every user has to implement
their own search.

Yes I ran into the same problem and it's annoying. It broke
originally when top down mmap was added I believe

Before the augmented rbtree it was potentially very expensive, but now
it should be cheap.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
