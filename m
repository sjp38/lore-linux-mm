Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 366A96B0439
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 16:27:08 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id x63so131626893pfx.7
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 13:27:08 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b62si862485pfd.138.2017.03.09.13.27.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 13:27:07 -0800 (PST)
Date: Thu, 9 Mar 2017 13:27:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: "mm: fix lazyfree BUG_ON check in try_to_unmap_one()" build
 error
Message-Id: <20170309132706.1cb4fc7d2e846923eedf788c@linux-foundation.org>
In-Reply-To: <20170309060226.GB854@bbox>
References: <20170309042908.GA26702@jagdpanzerIV.localdomain>
	<20170309060226.GB854@bbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 9 Mar 2017 15:02:26 +0900 Minchan Kim <minchan@kernel.org> wrote:

> Sergey reported VM_WARN_ON_ONCE returns void with !CONFIG_DEBUG_VM
> so we cannot use it as if's condition unlike WARN_ON.

Can we instead fix VM_WARN_ON_ONCE()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
