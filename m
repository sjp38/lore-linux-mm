Date: Wed, 16 Jan 2008 11:05:09 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] mmaped copy too slow?
In-Reply-To: <478CAB25.30300@grupopie.com>
References: <20080115100450.1180.KOSAKI.MOTOHIRO@jp.fujitsu.com> <478CAB25.30300@grupopie.com>
Message-Id: <20080116110200.11B4.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paulo Marques <pmarques@grupopie.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Paulo

> One thing you could also try is to pass MAP_POPULATE to mmap so that the 
> page tables are filled in at the time of the mmap, avoiding a lot of 
> page faults later.
> 
> Just my 2 cents,

OK, I will test your idea and report about tomorrow.
but I don't think page fault is major performance impact.

may be, below 2 things too big
  - stupid page reclaim
  - large cache pollution by memcpy.

Just my 2 cents :-p


- kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
