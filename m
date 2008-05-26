From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [patch 2/2] lockless get_user_pages
References: <20080525144847.GB25747@wotan.suse.de>
	<20080525145227.GC25747@wotan.suse.de>
Date: Mon, 26 May 2008 17:02:31 +0200
In-Reply-To: <20080525145227.GC25747@wotan.suse.de> (Nick Piggin's message of
	"Sun, 25 May 2008 16:52:27 +0200")
Message-ID: <8763t1w1ko.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, shaggy@austin.ibm.com, jens.axboe@oracle.com, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Hi Nick,

Nick Piggin <npiggin@suse.de> writes:

> Introduce a new "fast_gup" (for want of a better name right now)

Perhaps,

  * get_address_space
  * get_address_mappings
  * get_mapped_pages
  * get_page_mappings

Or s@get_@ref_@?

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
