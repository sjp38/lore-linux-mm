Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B2C66B0003
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 05:28:27 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id d18-v6so4124044wrq.3
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 02:28:27 -0700 (PDT)
Received: from mout.web.de (mout.web.de. [212.227.15.14])
        by mx.google.com with ESMTPS id w2-v6si4877989wmg.196.2018.07.01.02.28.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 02:28:25 -0700 (PDT)
Subject: Re: [PATCH v3 12/16] treewide: Use array_size() for kmalloc()-family
References: <20180601004233.37822-13-keescook@chromium.org>
 <b4c01457-7ea5-e7e3-be8b-f00fba6bac2b@users.sourceforge.net>
 <alpine.DEB.2.20.1807011100110.2748@hadrien>
From: SF Markus Elfring <elfring@users.sourceforge.net>
Message-ID: <a98a68c8-8b08-b3e9-da7b-ff57a2614f96@users.sourceforge.net>
Date: Sun, 1 Jul 2018 11:22:36 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1807011100110.2748@hadrien>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julia Lawall <julia.lawall@lip6.fr>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, kernel-hardening@lists.openwall.com
Cc: kernel-janitors@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Linus Torvalds <torvalds@linux-foundation.org>

>> * The repetition of such a constraint in subsequent SmPL rules could be avoided
>>   if inheritance will be used for this metavariable.
> 
> This is quite incorrect.

I suggest to consider additional software design options.


> Inheritance is only possible when a match of the previous rule has succeeded.

I agree with this information.


> If a rule never applies in a given file, the rules that inherit from it
> won't apply either.

I would like to point the possibility out to specify a source code search
which will find interesting function calls at least by an inital SmPL rule.


> Furthermore, what is inherited is the value, not the constraint.

This technical detail can be fine.


> If the original binding of alloc only ever matches kmalloc,
> then the inherited references will only match kmalloc too.

Can the desired search pattern be extended in significant ways?

Regards,
Markus
