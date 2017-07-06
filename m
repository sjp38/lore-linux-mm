Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9066B0292
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 01:19:52 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v26so10912875pfa.0
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 22:19:52 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id s12si757808pgo.318.2017.07.05.22.19.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 22:19:51 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id c24so1566097pfe.1
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 22:19:51 -0700 (PDT)
Date: Thu, 6 Jul 2017 14:19:59 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2] zswap: Zero-filled pages handling
Message-ID: <20170706051959.GD7195@jagdpanzerIV.localdomain>
References: <CGME20170702141959epcms5p32119c772b960e942da3a92e5a79d8c41@epcms5p3>
 <20170702141959epcms5p32119c772b960e942da3a92e5a79d8c41@epcms5p3>
 <CAC8qmcBa3ZBpw12AjbZ8bWuK5DW=wiXcURzomqXZXLrQhUWDhg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAC8qmcBa3ZBpw12AjbZ8bWuK5DW=wiXcURzomqXZXLrQhUWDhg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@redhat.com>
Cc: srividya.dr@samsung.com, "ddstreet@ieee.org" <ddstreet@ieee.org>, "penberg@kernel.org" <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, SHARAN ALLUR <sharan.allur@samsung.com>, SUNEEL KUMAR SURIMANI <suneel@samsung.com>, JUHUN KIM <juhunkim@samsung.com>, "srividya.desireddy@gmail.com" <srividya.desireddy@gmail.com>

On (07/02/17 20:28), Seth Jennings wrote:
> On Sun, Jul 2, 2017 at 9:19 AM, Srividya Desireddy
> > Zswap is a cache which compresses the pages that are being swapped out
> > and stores them into a dynamically allocated RAM-based memory pool.
> > Experiments have shown that around 10-20% of pages stored in zswap
> > are zero-filled pages (i.e. contents of the page are all zeros), but
> > these pages are handled as normal pages by compressing and allocating
> > memory in the pool.
> 
> I am somewhat surprised that this many anon pages are zero filled.
> 
> If this is true, then maybe we should consider solving this at the
> swap level in general, as we can de-dup zero pages in all swap
> devices, not just zswap.
> 
> That being said, this is a fair small change and I don't see anything
> objectionable.  However, I do think the better solution would be to do
> this at a higher level.

zero-filled pages are just 1 case. in general, it's better
to handle pages that are memset-ed with the same value (e.g.
memset(page, 0x01, page_size)). which includes, but not
limited to, 0x00. zram does it.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
