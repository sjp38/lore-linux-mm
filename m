Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1EB6B0033
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 04:28:28 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id h7so76560043wjy.6
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 01:28:28 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id m9si24132653wrb.103.2017.02.01.01.28.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 01:28:27 -0800 (PST)
Date: Wed, 1 Feb 2017 10:28:26 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/3] fs: break out of iomap_file_buffered_write on
	fatal signals
Message-ID: <20170201092826.GB1050@lst.de>
References: <20170201092706.9966-1-mhocko@kernel.org> <20170201092706.9966-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170201092706.9966-2-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

Looks fine,

Reviewed-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
