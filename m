Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE9346B03A4
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:49:06 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id w67so28044117wmd.3
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:49:06 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id c132si19482196wmh.29.2017.03.02.07.49.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 07:49:05 -0800 (PST)
Date: Thu, 2 Mar 2017 16:49:05 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/2] xfs: allow kmem_zalloc_greedy to fail
Message-ID: <20170302154905.GA4029@lst.de>
References: <20170302153002.GG3213@bfoster.bfoster> <20170302154541.16155-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170302154541.16155-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Brian Foster <bfoster@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Xiong Zhou <xzhou@redhat.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Michal Hocko <mhocko@suse.com>

Looks fine,

Reviewed-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
