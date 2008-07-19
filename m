Date: Sat, 19 Jul 2008 13:59:30 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH -mm] mm: more likely reclaim MADV_SEQUENTIAL mappings
Message-ID: <20080719135930.3b55381b@bree.surriel.com>
In-Reply-To: <87y73x4w6y.fsf@saeurebad.de>
References: <87y73x4w6y.fsf@saeurebad.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Nossum <vegard.nossum@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 19 Jul 2008 19:31:49 +0200
Johannes Weiner <hannes@saeurebad.de> wrote:

> File pages accessed only once through sequential-read mappings between
> fault and scan time are perfect candidates for reclaim.
> 
> This patch makes page_referenced() ignore these singular references and
> the pages stay on the inactive list where they likely fall victim to the
> next reclaim phase.

Which is exactly what the madvise man page says about pages in
MADV_SEQUENTIAL ranges.  Yay.

       MADV_SEQUENTIAL
              Expect  page  references  in sequential order.  (Hence, pages in
              the given range can be aggressively read ahead, and may be freed
              soon after they are accessed.)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
