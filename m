Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 22D946B0082
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 17:15:39 -0500 (EST)
Date: Wed, 15 Feb 2012 16:15:33 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
In-Reply-To: <4F3C28AF.9080005@tilera.com>
Message-ID: <alpine.DEB.2.00.1202151614510.28225@router.home>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>  <1327591185.2446.102.camel@twins>  <CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com>  <20120201170443.GE6731@somewhere.redhat.com>  <CAOtvUMc8L1nh2eGJez0x44UkfPCqd+xYQASsKOP76atopZi5mw@mail.gmail.com>
  <4F2AAEB9.9070302@tilera.com> <1328898816.25989.33.camel@laptop> <4F3C28AF.9080005@tilera.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Wed, 15 Feb 2012, Chris Metcalf wrote:

> The Tilera dataplane code is available on the "dataplane" branch (off of
> 3.3-rc3 at the moment):
>
> git://git.kernel.org/pub/scm/linux/kernel/git/cmetcalf/linux-tile.git

Looks like that patch is only for the tile architecture. Is there a
x86 version?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
