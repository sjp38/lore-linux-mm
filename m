Date: Fri, 16 May 2008 09:21:09 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] slub: record page flag overlays explicitly
In-Reply-To: <1210871999.0@pinky>
References: <exportbomb.1210871946@pinky> <1210871999.0@pinky>
Message-Id: <20080516092027.CDD2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> SLUB reuses two page bits for internal purposes, it overlays PG_active
> and PG_error.  This is hidden away in slub.c.  Document these overlays
> explicitly in the main page-flags enum along with all the others.
> 
> Signed-off-by: Andy Whitcroft <apw@shadowen.org>

Agreed.
I like your approach :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
