Date: Mon, 26 May 2008 13:37:51 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] page-flags: record page flag overlays explicitly
In-Reply-To: <1211560392.0@pinky>
References: <exportbomb.1211560342@pinky> <1211560392.0@pinky>
Message-Id: <20080526132853.4661.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi

Thank you nice patch.

> Some page flags are used for more than one purpose, for example
> PG_owner_priv_1.  Currently there are individual accessors for each user,
> each built using the common flag name far away from the bit definitions.
> This makes it hard to see all possible uses of these bits.
> 
> Now that we have a single enum to generate the bit orders it makes sense
> to express overlays in the same place.  So create per use aliases for
> this bit in the main page-flags enum and use those in the accessors.
> 
> Signed-off-by: Andy Whitcroft <apw@shadowen.org>

My review found no bug.

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
