Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BE4176B0007
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 07:47:46 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id a6so4831119pff.6
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 04:47:46 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k20si4949893pfb.120.2018.02.20.04.47.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 20 Feb 2018 04:47:45 -0800 (PST)
Date: Tue, 20 Feb 2018 04:47:42 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v7 15/61] xarray: Add xa_load
Message-ID: <20180220124742.GA21243@bombadil.infradead.org>
References: <20180219194556.6575-1-willy@infradead.org>
 <20180219194556.6575-16-willy@infradead.org>
 <CAOFm3uFQsycp1LpCwsMYJ0TynO03c5v3wBsNmE6mJxXaXyk+yA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOFm3uFQsycp1LpCwsMYJ0TynO03c5v3wBsNmE6mJxXaXyk+yA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philippe Ombredanne <pombredanne@nexb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Tue, Feb 20, 2018 at 08:34:06AM +0100, Philippe Ombredanne wrote:
> > +++ b/tools/testing/radix-tree/xarray-test.c
> > @@ -0,0 +1,56 @@
> > +/*
> > + * xarray-test.c: Test the XArray API
> > + * Copyright (c) 2017 Microsoft Corporation <mawilcox@microsoft.com>
> > + *
> > + * This program is free software; you can redistribute it and/or modify it
> > + * under the terms and conditions of the GNU General Public License,
> > + * version 2, as published by the Free Software Foundation.
> > + *
> > + * This program is distributed in the hope it will be useful, but WITHOUT
> > + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> > + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> > + * more details.
> > + */
> 
> Do you mind using SPDX tags per [1] rather that this fine but long legalese?
> Unless you are a legalese lover of course.

Argh, missed that one.

I'm more concerned with the documentation license, though.  I didn't
get a response from you to the email I sent Feb 12, Subject: License
documentation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
