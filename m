Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id C99ED6B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 11:45:35 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so46004661pad.3
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 08:45:35 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id oa11si36805031pdb.33.2015.03.18.08.45.34
        for <linux-mm@kvack.org>;
        Wed, 18 Mar 2015 08:45:34 -0700 (PDT)
Message-ID: <55099D9D.7000005@intel.com>
Date: Wed, 18 Mar 2015 08:45:33 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm: protect suid binaries against rowhammer with
 copy-on-read mappings
References: <20150318083040.7838.76933.stgit@zurg>	<550987AD.8020409@intel.com> <CALYGNiPPgaKb6_Pyo1SZ8sjgSbgC0yXFfZ2OwUN5=mSdTypcAA@mail.gmail.com>
In-Reply-To: <CALYGNiPPgaKb6_Pyo1SZ8sjgSbgC0yXFfZ2OwUN5=mSdTypcAA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>

On 03/18/2015 08:08 AM, Konstantin Khlebnikov wrote:
> It seems the only option is memory zoning: kernel should allocate all
> normal memory for userspace from isolated area which is kept far far
> away from important data.

Yeah, except that the kernel has a pretty hard time telling which data
is important.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
