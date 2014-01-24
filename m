Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0B9FC6B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 10:25:12 -0500 (EST)
Received: by mail-we0-f171.google.com with SMTP id w61so2841340wes.30
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 07:25:12 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n3si738217wjr.169.2014.01.24.07.25.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jan 2014 07:25:12 -0800 (PST)
Date: Fri, 24 Jan 2014 15:25:09 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/9] rename p->numa_faults to numa_faults_memory
Message-ID: <20140124152509.GY4963@suse.de>
References: <1390342811-11769-1-git-send-email-riel@redhat.com>
 <1390342811-11769-3-git-send-email-riel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1390342811-11769-3-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@redhat.com, chegu_vinod@hp.com

On Tue, Jan 21, 2014 at 05:20:04PM -0500, riel@redhat.com wrote:
> From: Rik van Riel <riel@redhat.com>
> 
> In order to get a more consistent naming scheme, making it clear
> which fault statistics track memory locality, and which track
> CPU locality, rename the memory fault statistics.
> 
> Suggested-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Rik van Riel <riel@redhat.com>

Thanks.

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
