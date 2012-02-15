Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id D165E6B0083
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 18:44:45 -0500 (EST)
Message-ID: <4F3C4364.6020401@tilera.com>
Date: Wed, 15 Feb 2012 18:44:36 -0500
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>  <1327591185.2446.102.camel@twins>  <CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com>  <20120201170443.GE6731@somewhere.redhat.com>  <CAOtvUMc8L1nh2eGJez0x44UkfPCqd+xYQASsKOP76atopZi5mw@mail.gmail.com>  <4F2AAEB9.9070302@tilera.com> <1328898816.25989.33.camel@laptop> <4F3C28AF.9080005@tilera.com> <alpine.DEB.2.00.1202151614510.28225@router.home>
In-Reply-To: <alpine.DEB.2.00.1202151614510.28225@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On 2/15/2012 5:15 PM, Christoph Lameter wrote:
> On Wed, 15 Feb 2012, Chris Metcalf wrote:
>
>> The Tilera dataplane code is available on the "dataplane" branch (off of
>> 3.3-rc3 at the moment):
>>
>> git://git.kernel.org/pub/scm/linux/kernel/git/cmetcalf/linux-tile.git
> Looks like that patch is only for the tile architecture. Is there a
> x86 version?

No, we haven't looked at doing that yet.  Part of that would be moving
things that are now in arch-specific area (like the <asm/dataplane.h>
header) to include/linux/, etc.; since this patch isn't ready for merge
yet, there are plenty of cleanups like that we'd want to do.  Probably the
next step is to figure out how to integrate what Tilera has done with the
nohz cpuset stuff that Frederic has so we retain the best of both worlds.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
