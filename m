Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 986BB6B006C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 00:22:50 -0400 (EDT)
Date: Wed, 30 May 2012 21:22:49 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH v4] slab/mempolicy: always use local policy from
 interrupt context
Message-ID: <20120531042249.GG9850@tassilo.jf.intel.com>
References: <1336431315-29736-1-git-send-email-andi@firstfloor.org>
 <1338429749-5780-1-git-send-email-tdmackey@twitter.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1338429749-5780-1-git-send-email-tdmackey@twitter.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Mackey <tdmackey@twitter.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, cl@linux.com

> [tdmackey@twitter.com: Rework patch logic and avoid dereference of current 
> task if in interrupt context.]

avoiding this reference doesn't make sense, it's totally valid.
This is based on a older version. I sent the fixed one some time ago.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
