Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id DD6036B027D
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 02:26:09 -0500 (EST)
Received: by mail-io0-f174.google.com with SMTP id g203so204048296iof.2
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 23:26:09 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id rv2si37456749igb.32.2016.02.22.23.26.08
        for <linux-mm@kvack.org>;
        Mon, 22 Feb 2016 23:26:09 -0800 (PST)
Date: Tue, 23 Feb 2016 16:27:21 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2] mm/slab: re-implement pfmemalloc support
Message-ID: <20160223072721.GB4148@js1304-P5Q-DELUXE>
References: <1455176087-18570-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20160222115242.GB27753@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160222115242.GB27753@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 22, 2016 at 11:52:42AM +0000, Mel Gorman wrote:
> On Thu, Feb 11, 2016 at 04:34:47PM +0900, js1304@gmail.com wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > Current implementation of pfmemalloc handling in SLAB has some problems.
> > 
> 
> Tested-by: Mel Gorman <mgorman@techsingularity.net>

Thanks for testing!
> 
> The test completed successfully if a lot slower. However, the time to
> completion is not reliable anyway and subject to a number of factors so
> it's not of concern.

Okay. Not entirely happy result but agree that your statement.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
