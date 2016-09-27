Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 32D6728027B
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 09:34:08 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 92so37449883iom.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 06:34:08 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id d199si13440010itc.63.2016.09.27.06.34.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 06:34:07 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id my20so735534pab.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 06:34:07 -0700 (PDT)
Message-ID: <1474983244.28155.48.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH v2] fs/select: add vmalloc fallback for select(2)
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 27 Sep 2016 06:34:04 -0700
In-Reply-To: <6e62a278-4ac3-a866-51c6-e32511406aba@suse.cz>
References: <20160922164359.9035-1-vbabka@suse.cz>
	 <20160926170105.517f74cd67ecdd5ef73e1865@linux-foundation.org>
	 <1474940324.28155.44.camel@edumazet-glaptop3.roam.corp.google.com>
	 <6e62a278-4ac3-a866-51c6-e32511406aba@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, netdev@vger.kernel.org

On Tue, 2016-09-27 at 10:13 +0200, Vlastimil Babka wrote:

> I doubt anyone runs that in production, especially if performance is of concern.
> 

I doubt anyone serious runs select() on a large fd set in production.

Last time I used it was in last century.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
