Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 85E476B0383
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:54:09 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id v2so4320313wmc.0
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:54:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l46-v6si2693239edd.291.2018.05.09.00.54.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 00:54:08 -0700 (PDT)
Date: Wed, 9 May 2018 09:54:07 +0200
From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: Re: [PATCH 01/10] mempool: Add mempool_init()/mempool_exit()
Message-ID: <20180509075407.oz7l6gkolepciudx@linux-x5ow.site>
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
 <20180509013358.16399-2-kent.overstreet@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180509013358.16399-2-kent.overstreet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kent Overstreet <kent.overstreet@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Ingo Molnar <mingo@kernel.org>

On Tue, May 08, 2018 at 09:33:49PM -0400, Kent Overstreet wrote:
> +/**
> + * mempool_destroy - exit a mempool initialized with mempool_init()

^ mempool_exit()

-- 
Johannes Thumshirn                                          Storage
jthumshirn@suse.de                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nurnberg
GF: Felix Imendorffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nurnberg)
Key fingerprint = EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850
