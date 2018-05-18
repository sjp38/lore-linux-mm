Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 965826B05C2
	for <linux-mm@kvack.org>; Fri, 18 May 2018 04:58:44 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y9-v6so735749wrg.22
        for <linux-mm@kvack.org>; Fri, 18 May 2018 01:58:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g16-v6si4711807edg.21.2018.05.18.01.58.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 May 2018 01:58:43 -0700 (PDT)
Date: Fri, 18 May 2018 10:58:42 +0200
From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: Re: [PATCH 03/10] block: Add bioset_init()/bioset_exit()
Message-ID: <20180518085842.j7cqesm3ojvntkh7@linux-x5ow.site>
References: <20180518074918.13816-1-kent.overstreet@gmail.com>
 <20180518074918.13816-6-kent.overstreet@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180518074918.13816-6-kent.overstreet@gmail.com>
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
