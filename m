Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8FBE36B000A
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 13:47:43 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id t192so20697989iof.6
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 10:47:43 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0197.hostedemail.com. [216.40.44.197])
        by mx.google.com with ESMTPS id d31si1484348ioj.98.2018.02.14.10.47.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 10:47:42 -0800 (PST)
Message-ID: <1518634058.3678.15.camel@perches.com>
Subject: Re: [PATCH 0/2] Add kvzalloc_struct to complement kvzalloc_array
From: Joe Perches <joe@perches.com>
Date: Wed, 14 Feb 2018 10:47:38 -0800
In-Reply-To: <20180214182618.14627-1-willy@infradead.org>
References: <20180214182618.14627-1-willy@infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wed, 2018-02-14 at 10:26 -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> We all know the perils of multiplying a value provided from userspace
> by a constant and then allocating the resulting number of bytes.  That's
> why we have kvmalloc_array(), so we don't have to think about it.
> This solves the same problem when we embed one of these arrays in a
> struct like this:
> 
> struct {
> 	int n;
> 	unsigned long array[];
> };

I think expanding the number of allocation functions
is not necessary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
