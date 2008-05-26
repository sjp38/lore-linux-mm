Date: Mon, 26 May 2008 13:41:49 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] slob: record page flag overlays explicitly
In-Reply-To: <1211560412.0@pinky>
References: <exportbomb.1211560342@pinky> <1211560412.0@pinky>
Message-Id: <20080526134123.4667.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> 
> SLOB reuses two page bits for internal purposes, it overlays PG_active
> and PG_private.  This is hidden away in slob.c.  Document these overlays
> explicitly in the main page-flags enum along with all the others.
> 
> Signed-off-by: Andy Whitcroft <apw@shadowen.org>

I dont have SLOB box.
but My review found no bug.

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
