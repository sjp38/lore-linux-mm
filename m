Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id ED7496B0038
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 18:31:54 -0500 (EST)
Received: by ioir85 with SMTP id r85so132198018ioi.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 15:31:54 -0800 (PST)
Received: from mail-io0-x231.google.com (mail-io0-x231.google.com. [2607:f8b0:4001:c06::231])
        by mx.google.com with ESMTPS id i4si8845150iga.75.2015.12.04.15.31.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 15:31:54 -0800 (PST)
Received: by ioir85 with SMTP id r85so132197874ioi.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 15:31:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151204011424.8A36E365@viggo.jf.intel.com>
References: <20151204011424.8A36E365@viggo.jf.intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 4 Dec 2015 15:31:34 -0800
Message-ID: <CALCETrXwVb99hAvqR2o54aPwtpr8oubROtiRt45SiYRfUTAxCw@mail.gmail.com>
Subject: Re: [PATCH 00/34] x86: Memory Protection Keys (v5)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Thu, Dec 3, 2015 at 5:14 PM, Dave Hansen <dave@sr71.net> wrote:
> Memory Protection Keys for User pages is a CPU feature which will
> first appear on Skylake Servers, but will also be supported on
> future non-server parts.  It provides a mechanism for enforcing
> page-based protections, but without requiring modification of the
> page tables when an application changes protection domains.  See
> the Documentation/ patch for more details.

What, if anything, happened to the signal handling parts?

Also, do you have a git tree for this somewhere?  I can't actually
enable it (my laptop, while very shiny, is not a Skylake server), but
I can poke around a bit.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
