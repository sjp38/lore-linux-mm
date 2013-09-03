Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 845EF6B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 19:02:51 -0400 (EDT)
Date: Tue, 3 Sep 2013 19:02:40 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm/vmscan: make global_reclaim() inline
Message-ID: <20130903230240.GD1412@cmpxchg.org>
References: <20130822053956.GA10795@larmbr-lcx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130822053956.GA10795@larmbr-lcx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: larmbr <nasa4836@gmail.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, riel@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Thu, Aug 22, 2013 at 01:39:56PM +0800, larmbr wrote:
> Though Gcc is likely to inline them, we should better
> explictly do it manually, and also, this serve to document 
> this fact.

Why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
