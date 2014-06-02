Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id A1F506B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 10:29:58 -0400 (EDT)
Received: by mail-la0-f50.google.com with SMTP id b8so2634331lan.9
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 07:29:57 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ub4si25745371wjc.56.2014.06.02.07.29.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 07:29:57 -0700 (PDT)
Date: Mon, 2 Jun 2014 10:29:00 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm/page-writeback.c: remove outdated comment
Message-ID: <20140602142900.GN2878@cmpxchg.org>
References: <1401702440-1884-1-git-send-email-nasa4836@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1401702440-1884-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, cldu@marvell.com, handai.szj@taobao.com, paul.gortmaker@windriver.com, mpatlasov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 02, 2014 at 05:47:20PM +0800, Jianyu Zhan wrote:
> There is an orphaned prehistoric comment , which used to be against
> get_dirty_limits(), the dawn of global_dirtyable_memory().
> 
> Back then, the implementation of get_dirty_limits() is complicated and
> full of magic numbers, so this comment is necessary. But we now
> use the clear and neat global_dirtyable_memory(), which renders this
> comment ambiguous and useless. Remove it.
> 
> Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
