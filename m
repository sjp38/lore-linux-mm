Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 178CF6B005D
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 14:21:17 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so1694533pbb.14
        for <linux-mm@kvack.org>; Wed, 01 Aug 2012 11:21:16 -0700 (PDT)
Date: Wed, 1 Aug 2012 11:21:12 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 1/4] hashtable: introduce a small and naive hashtable
Message-ID: <20120801182112.GC15477@google.com>
References: <1343757920-19713-1-git-send-email-levinsasha928@gmail.com>
 <1343757920-19713-2-git-send-email-levinsasha928@gmail.com>
 <20120731182330.GD21292@google.com>
 <50197348.9010101@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50197348.9010101@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com

On Wed, Aug 01, 2012 at 08:19:52PM +0200, Sasha Levin wrote:
> If we switch to using functions, we could no longer hide it anywhere
> (we'd need to either turn the buckets into a struct, or have the
> user pass it around to all functions).

Create an outer struct hash_table which remembers the size?

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
