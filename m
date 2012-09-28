Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 4CA566B0070
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 09:20:03 -0400 (EDT)
Date: Fri, 28 Sep 2012 14:19:49 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] make GFP_NOTRACK flag unconditional
Message-ID: <20120928131949.GE29125@suse.de>
References: <1348826194-21781-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1348826194-21781-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

On Fri, Sep 28, 2012 at 01:56:34PM +0400, Glauber Costa wrote:
> There was a general sentiment in a recent discussion (See
> https://lkml.org/lkml/2012/9/18/258) that the __GFP flags should be
> defined unconditionally. Currently, the only offender is GFP_NOTRACK,
> which is conditional to KMEMCHECK.
> 
> This simple patch makes it unconditional.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Christoph Lameter <cl@linux.com>
> CC: Mel Gorman <mgorman@suse.de>
> CC: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
