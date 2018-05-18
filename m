Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E9FA06B059A
	for <linux-mm@kvack.org>; Fri, 18 May 2018 04:23:39 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id t185-v6so2952070wmt.8
        for <linux-mm@kvack.org>; Fri, 18 May 2018 01:23:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x4-v6si2052007edq.436.2018.05.18.01.23.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 May 2018 01:23:38 -0700 (PDT)
Date: Fri, 18 May 2018 10:23:38 +0200
From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: Re: [PATCH 02/10] block: Convert bio_set to mempool_init()
Message-ID: <20180518082338.kh2gqck2zvqf7fjs@linux-x5ow.site>
References: <20180518074918.13816-1-kent.overstreet@gmail.com>
 <20180518074918.13816-4-kent.overstreet@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180518074918.13816-4-kent.overstreet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kent Overstreet <kent.overstreet@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Ingo Molnar <mingo@kernel.org>

On Fri, May 18, 2018 at 03:49:01AM -0400, Kent Overstreet wrote:
> Minor performance improvement by getting rid of pointer indirections
> from allocation/freeing fastpaths.

Reviewed-by: Johannes Thumshirn <jthumshirn@suse.de>

Although I'd prefer numbers in the changelog when claiming a
performance improvement.

-- 
Johannes Thumshirn                                          Storage
jthumshirn@suse.de                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nurnberg
GF: Felix Imendorffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nurnberg)
Key fingerprint = EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850
