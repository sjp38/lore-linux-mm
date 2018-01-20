Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 905AC6B0033
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 19:15:31 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id e198so1914670oig.23
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 16:15:31 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 63sor3919428oig.258.2018.01.19.16.15.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Jan 2018 16:15:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180118000602.5527-1-jschoenh@amazon.de>
References: <20180118000602.5527-1-jschoenh@amazon.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 19 Jan 2018 16:15:29 -0800
Message-ID: <CAPcyv4jxHuo5kJhZ7T5dseNmW0qKtnjc98k9KS=TKRxV_FXW4g@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: Fix memory size alignment in devm_memremap_pages_release()
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Jan_H=2E_Sch=C3=B6nherr?= <jschoenh@amazon.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Jan 17, 2018 at 4:06 PM, Jan H. Sch=C3=B6nherr <jschoenh@amazon.de>=
 wrote:
> The functions devm_memremap_pages() and devm_memremap_pages_release() use
> different ways to calculate the section-aligned amount of memory. The
> latter function may use an incorrect size if the memory region is small
> but straddles a section border.
>
> Use the same code for both.
>
> Fixes: 5f29a77cd957 ("mm: fix mixed zone detection in devm_memremap_pages=
")
> Signed-off-by: Jan H. Sch=C3=B6nherr <jschoenh@amazon.de>

Looks good to me, applied for 4.16.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
