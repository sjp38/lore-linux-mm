Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 166836B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 21:49:10 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d5so738267pfe.2
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 18:49:10 -0700 (PDT)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id l6si997862pgu.76.2017.06.14.18.49.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 18:49:09 -0700 (PDT)
Received: by mail-pf0-x230.google.com with SMTP id x63so512187pff.3
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 18:49:09 -0700 (PDT)
Date: Wed, 14 Jun 2017 18:49:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, vmpressure: free the same pointer we allocated
In-Reply-To: <20170613191820.GA20003@elgon.mountain>
Message-ID: <alpine.DEB.2.10.1706141847460.77174@chino.kir.corp.google.com>
References: <20170613191820.GA20003@elgon.mountain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Vinayak Menon <vinmenon@codeaurora.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On Tue, 13 Jun 2017, Dan Carpenter wrote:

> We keep incrementing "spec" as we parse the args so we end up calling
> kfree() on a modified of spec.  It probably works or this would have
> been caught in testing, but it looks weird.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
