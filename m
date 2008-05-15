Date: Thu, 15 May 2008 10:28:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/3] page-flags: record page flag overlays explicitly
In-Reply-To: <1210871989.0@pinky>
Message-ID: <Pine.LNX.4.64.0805151026410.18354@schroedinger.engr.sgi.com>
References: <exportbomb.1210871946@pinky> <1210871989.0@pinky>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 May 2008, Andy Whitcroft wrote:

> Now that we have a single enum to generate the bit orders it makes sense
> to express overlays in the same place.  So create per use aliases for
> this bit in the main page-flags enum and use those in the accessors.

Well I thought it would be better to have the overlays defined when the 
PAGEFLAGS_xx macro is used. If that is done then every PG_xxx has a unique 
id. The aliasing is then only through PageXXXX() using a PG_yyy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
