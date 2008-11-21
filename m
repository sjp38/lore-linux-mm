From: Petr Tesarik <ptesarik@suse.cz>
Subject: Re: [PATCH -mm] vmscan: bail out of page reclaim after swap_cluster_max pages
Date: Fri, 21 Nov 2008 12:59:30 +0100
References: <20081113171208.6985638e@bree.surriel.com> <20081119165443.GB26749@csn.ul.ie>
In-Reply-To: <20081119165443.GB26749@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200811211259.30760.ptesarik@suse.cz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dne Wednesday 19 of November 2008 17:54:44 Mel Gorman napsal(a):
>[...]
> I was going to ask if it was easier to go OOM now, but even under very high
> stress, we should be making forward progress. It's just in smaller steps so
> I can't see it causing a problem.

Actually, I had to apply a very similar patch the other day to reduce the time 
the system was unresponsive because of the OOM-killer, so I tested OOM 
situations quite a lot, and it did not cause any problem.

Petr Tesarik

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
