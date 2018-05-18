Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 52B4D6B05C3
	for <linux-mm@kvack.org>; Fri, 18 May 2018 05:00:06 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b83-v6so2999240wme.7
        for <linux-mm@kvack.org>; Fri, 18 May 2018 02:00:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f18-v6si106307edd.11.2018.05.18.02.00.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 May 2018 02:00:05 -0700 (PDT)
Date: Fri, 18 May 2018 11:00:04 +0200
From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: Re: [PATCH 08/10] block: Add warning for bi_next not NULL in
 bio_endio()
Message-ID: <20180518090004.i7e5kkrle4mjfqzv@linux-x5ow.site>
References: <20180518074918.13816-1-kent.overstreet@gmail.com>
 <20180518074918.13816-17-kent.overstreet@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180518074918.13816-17-kent.overstreet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kent Overstreet <kent.overstreet@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Ingo Molnar <mingo@kernel.org>

Looks good,
Reviewed-by: Johannes Thumshirn <jthumshirn@suse.de>
-- 
Johannes Thumshirn                                          Storage
jthumshirn@suse.de                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nurnberg
GF: Felix Imendorffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nurnberg)
Key fingerprint = EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850
