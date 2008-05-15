Date: Thu, 15 May 2008 10:29:16 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/3] slub: record page flag overlays explicitly
In-Reply-To: <1210871999.0@pinky>
Message-ID: <Pine.LNX.4.64.0805151028130.18354@schroedinger.engr.sgi.com>
References: <exportbomb.1210871946@pinky> <1210871999.0@pinky>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 May 2008, Andy Whitcroft wrote:
 
> SLUB reuses two page bits for internal purposes, it overlays PG_active
> and PG_error.  This is hidden away in slub.c.  Document these overlays
> explicitly in the main page-flags enum along with all the others.

Hmmm.. Add the definitions also to page-flags.h?

SLABFLAG(Frozen, PG_active)
SLABFLAG(Debug, PG_error)
?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
