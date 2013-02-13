Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 983236B0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 06:10:37 -0500 (EST)
Received: by mail-ea0-f172.google.com with SMTP id f13so457927eaa.17
        for <linux-mm@kvack.org>; Wed, 13 Feb 2013 03:10:35 -0800 (PST)
Date: Wed, 13 Feb 2013 12:10:31 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86: mm: Check if PUD is large when validating a kernel
 address v2
Message-ID: <20130213111031.GA11320@gmail.com>
References: <20130211145236.GX21389@suse.de>
 <20130213110202.GI4100@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130213110202.GI4100@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org


* Mel Gorman <mgorman@suse.de> wrote:

> Andrew or Ingo, please pick up.

Already did - will push it out later today.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
