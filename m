Date: Fri, 23 May 2008 10:08:40 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/3] explicitly document overloaded page flags V2
In-Reply-To: <exportbomb.1211560342@pinky>
Message-ID: <Pine.LNX.4.64.0805231006100.1847@schroedinger.engr.sgi.com>
References: <exportbomb.1211560342@pinky>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Looks good.

If we want to do the bit aliasing at the PG_xxx layer then there may be a 
way to simplify the page flag generation function because the xxx in 
PG_xxx is always the lower case of the PageXxx case. So we could remove 
one parameter if we can find some kind of cpp function that can lowercase 
a text.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
