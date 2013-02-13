Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 39E926B0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 06:14:46 -0500 (EST)
Date: Wed, 13 Feb 2013 11:14:40 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] x86: mm: Check if PUD is large when validating a kernel
 address v2
Message-ID: <20130213111440.GJ4100@suse.de>
References: <20130211145236.GX21389@suse.de>
 <20130213110202.GI4100@suse.de>
 <20130213111031.GA11320@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130213111031.GA11320@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org

On Wed, Feb 13, 2013 at 12:10:31PM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > Andrew or Ingo, please pick up.
> 
> Already did - will push it out later today.
> 

Whoops, thanks. Sorry for the noise.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
