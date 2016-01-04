Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 685606B0007
	for <linux-mm@kvack.org>; Sun,  3 Jan 2016 20:37:08 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id b14so164414158wmb.1
        for <linux-mm@kvack.org>; Sun, 03 Jan 2016 17:37:08 -0800 (PST)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id ww6si142000163wjb.205.2016.01.03.17.37.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jan 2016 17:37:07 -0800 (PST)
Received: by mail-wm0-x22c.google.com with SMTP id f206so193193700wmf.0
        for <linux-mm@kvack.org>; Sun, 03 Jan 2016 17:37:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <968b4c079271431292fddfa49ceacff576be6849.1451869360.git.tony.luck@intel.com>
References: <cover.1451869360.git.tony.luck@intel.com>
	<968b4c079271431292fddfa49ceacff576be6849.1451869360.git.tony.luck@intel.com>
Date: Sun, 3 Jan 2016 17:37:07 -0800
Message-ID: <CA+8MBbKuOHHwYeFHFePAts=DE=iR4aQUcfjDzGEg7u5ihTDmLg@mail.gmail.com>
Subject: Re: [PATCH v6 1/4] x86: Clean up extable entry format (and free up a bit)
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86-ML <x86@kernel.org>

On Wed, Dec 30, 2015 at 9:59 AM, Andy Lutomirski <luto@amacapital.net> wrote:
> This adds two bits of fixup class information to a fixup entry,
> generalizing the uaccess_err hack currently in place.
>
> Forward-ported-from-3.9-by: Tony Luck <tony.luck@intel.com>
> Signed-off-by: Andy Lutomirski <luto@amacapital.net>

Crivens!  I messed up when "git cherrypick"ing this and "git
format-patch"ing it.

I didn't mean to forge Andy's From line when sending this out (just to have a
From: line to give him credit.for the patch).

Big OOPs ... this is "From:" me ... not Andy!

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
