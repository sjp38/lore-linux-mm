Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 30E726B0038
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 08:40:32 -0400 (EDT)
Received: by wifw1 with SMTP id w1so143044374wif.0
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 05:40:31 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n2si24127151wic.122.2015.06.02.05.40.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Jun 2015 05:40:30 -0700 (PDT)
Date: Tue, 2 Jun 2015 13:40:26 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/4] sunrpc: if we're closing down a socket, clear
 memalloc on it first
Message-ID: <20150602124025.GG26425@suse.de>
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
