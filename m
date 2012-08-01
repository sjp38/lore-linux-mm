Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id D52576B004D
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 18:46:00 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2049592pbb.14
        for <linux-mm@kvack.org>; Wed, 01 Aug 2012 15:46:00 -0700 (PDT)
Date: Wed, 1 Aug 2012 15:45:56 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 1/4] hashtable: introduce a small and naive hashtable
Message-ID: <20120801224556.GF15477@google.com>
References: <1343757920-19713-1-git-send-email-levinsasha928@gmail.com>
 <1343757920-19713-2-git-send-email-levinsasha928@gmail.com>
 <20120731182330.GD21292@google.com>
 <50197348.9010101@gmail.com>
 <20120801182112.GC15477@google.com>
 <50197460.8010906@gmail.com>
 <20120801182749.GD15477@google.com>
 <50197E4A.7020408@gmail.com>
 <20120801202432.GE15477@google.com>
 <5019B0B4.1090102@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5019B0B4.1090102@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com

On Thu, Aug 02, 2012 at 12:41:56AM +0200, Sasha Levin wrote:
> How would your DEFINE_HASHTABLE look like if we got for the simple
> 'struct hash_table' approach?

I think defining a different enclosing anonymous struct which the
requested number of array entries and then aliasing the actual
hash_table to that symbol should work.  It's rather horrible and I'm
not sure it's worth the trouble.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
