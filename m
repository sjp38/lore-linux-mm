Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 0882D6B004A
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 10:11:36 -0500 (EST)
Message-ID: <1329318679.2293.140.camel@twins>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 15 Feb 2012 16:11:19 +0100
In-Reply-To: <CAOtvUMf11CxFV+FR8YCjqaoEWojGT7oX46_QamjCkXkHzsW3-A@mail.gmail.com>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
	 <1327591185.2446.102.camel@twins>
	 <CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com>
	 <20120201170443.GE6731@somewhere.redhat.com>
	 <CAOtvUMc8L1nh2eGJez0x44UkfPCqd+xYQASsKOP76atopZi5mw@mail.gmail.com>
	 <4F2AAEB9.9070302@tilera.com> <1328899105.25989.37.camel@laptop>
	 <CAOtvUMf11CxFV+FR8YCjqaoEWojGT7oX46_QamjCkXkHzsW3-A@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Chris Metcalf <cmetcalf@tilera.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Fri, 2012-02-10 at 22:24 +0200, Gilad Ben-Yossef wrote:
> I think the concept of giving the task some way to know if the tick is
> disabled or not is nice.
> Not sure the exact feature and surely not the interface are what we
> should adopt - maybe
> allow registering to receive a signal at the end of the tick when it
> is disabled an re-enabled?=20

Fair enough, I indeed missed that property. And yes that makes sense.=20

It might be a tad tricky to implement as things currently stand, because
AFAICR Frederic's stuff re-enables the tick on kernel entry (syscall)
things like signal delivery or a blocking wait for it might be 'fun'.

But I'll have to defer to Frederic, its been too long since I've seen
his patches to remember most details.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
