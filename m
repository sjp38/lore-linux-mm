Date: Thu, 6 Nov 2008 08:56:19 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC][PATCH] mm: the page of MIGRATE_RESERVE don't insert into
 pcp
In-Reply-To: <20081106091431.0D2A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0811060856020.3595@quilx.com>
References: <20081106091431.0D2A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

And the fastpath gets even more complex. Sigh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
