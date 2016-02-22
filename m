Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 629C5828E2
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 06:52:46 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id a4so158844229wme.1
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 03:52:46 -0800 (PST)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id y72si32281185wmc.48.2016.02.22.03.52.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 Feb 2016 03:52:44 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 7DCC4985B5
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 11:52:44 +0000 (UTC)
Date: Mon, 22 Feb 2016 11:52:42 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2] mm/slab: re-implement pfmemalloc support
Message-ID: <20160222115242.GB27753@techsingularity.net>
References: <1455176087-18570-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1455176087-18570-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, Feb 11, 2016 at 04:34:47PM +0900, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Current implementation of pfmemalloc handling in SLAB has some problems.
> 

Tested-by: Mel Gorman <mgorman@techsingularity.net>

The test completed successfully if a lot slower. However, the time to
completion is not reliable anyway and subject to a number of factors so
it's not of concern.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
