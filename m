Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 020C46B006C
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 08:38:12 -0400 (EDT)
Received: by wgv5 with SMTP id 5so138919723wgv.1
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 05:38:11 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id la1si6731000wjc.209.2015.06.02.05.38.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Jun 2015 05:38:10 -0700 (PDT)
Date: Tue, 2 Jun 2015 13:38:06 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/4] sunrpc: if we're closing down a socket, clear
 memalloc on it first
Message-ID: <20150602123806.GF26425@suse.de>
References: <1432987393-15604-1-git-send-email-jeff.layton@primarydata.com>
 <1432987393-15604-4-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1432987393-15604-4-git-send-email-jeff.layton@primarydata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jerome Marchand <jmarchan@redhat.com>

On Sat, May 30, 2015 at 08:03:12AM -0400, Jeff Layton wrote:
> We currently increment the memalloc_socks counter if we have a xprt that
> is associated with a swapfile. That socket can be replaced however
> during a reconnect event, and the memalloc_socks counter is never
> decremented if that occurs.
> 
> When tearing down a xprt socket, check to see if the xprt is set up for
> swapping and sk_clear_memalloc before releasing the socket if so.
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
