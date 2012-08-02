Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id AC74F6B005D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 05:35:47 -0400 (EDT)
Date: Thu, 2 Aug 2012 02:35:36 -0700
From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [RFC 1/4] hashtable: introduce a small and naive hashtable
Message-ID: <20120802093536.GA23089@leaf>
References: <1343757920-19713-1-git-send-email-levinsasha928@gmail.com>
 <1343757920-19713-2-git-send-email-levinsasha928@gmail.com>
 <20120731182330.GD21292@google.com>
 <50197348.9010101@gmail.com>
 <20120801182112.GC15477@google.com>
 <50197460.8010906@gmail.com>
 <20120801182749.GD15477@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120801182749.GD15477@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com

On Wed, Aug 01, 2012 at 11:27:49AM -0700, Tejun Heo wrote:
> On Wed, Aug 01, 2012 at 08:24:32PM +0200, Sasha Levin wrote:
> > On 08/01/2012 08:21 PM, Tejun Heo wrote:
> > > On Wed, Aug 01, 2012 at 08:19:52PM +0200, Sasha Levin wrote:
> > >> If we switch to using functions, we could no longer hide it anywhere
> > >> (we'd need to either turn the buckets into a struct, or have the
> > >> user pass it around to all functions).
> > > 
> > > Create an outer struct hash_table which remembers the size?
> > 
> > Possible. I just wanted to avoid creating new structs where they're not really required.
> > 
> > Do you think it's worth it for eliminating those two macros?
> 
> What if someone wants to allocate hashtable dynamically which isn't
> too unlikely?

In particular, once this goes in, I'd like to add RCU-based hash
resizing to it, which will require wrapping the hash table in a struct
that also contains the size.  So, please do consider having such a
struct rather than relying on static array sizes.

- Josh Triplett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
