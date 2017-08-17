Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1B2436B025F
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 00:56:19 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y96so10423029wrc.10
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 21:56:19 -0700 (PDT)
Received: from mail-wr0-x229.google.com (mail-wr0-x229.google.com. [2a00:1450:400c:c0c::229])
        by mx.google.com with ESMTPS id z21si2751814edc.200.2017.08.16.21.56.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 21:56:17 -0700 (PDT)
Received: by mail-wr0-x229.google.com with SMTP id z91so23548405wrc.4
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 21:56:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170816224650.1089-3-labbott@redhat.com>
References: <20170816224650.1089-1-labbott@redhat.com> <20170816224650.1089-3-labbott@redhat.com>
From: Nick Kralevich <nnk@google.com>
Date: Wed, 16 Aug 2017 21:56:15 -0700
Message-ID: <CAFJ0LnHdAwAHJipwqOHzdLktCL+Ttdywuogk0ORHqn7eauRLkA@mail.gmail.com>
Subject: Re: [kernel-hardening] [PATCHv2 2/2] extract early boot entropy from
 the passed cmdline
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Kees Cook <keescook@chromium.org>, Daniel Micay <danielmicay@gmail.com>, kernel-hardening@lists.openwall.com, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Aug 16, 2017 at 3:46 PM, Laura Abbott <labbott@redhat.com> wrote:
> From: Daniel Micay <danielmicay@gmail.com>
>
> Existing Android bootloaders usually pass data useful as early entropy
> on the kernel command-line. It may also be the case on other embedded
> systems. Sample command-line from a Google Pixel running CopperheadOS:
>

Why is it better to put this into the kernel, rather than just rely on
the existing userspace functionality which does exactly the same
thing? This is what Android already does today:
https://android-review.googlesource.com/198113

-- Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
