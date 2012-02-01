Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 8DD986B13F0
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 12:58:16 -0500 (EST)
Message-ID: <1328119072.2446.264.camel@twins>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 01 Feb 2012 18:57:52 +0100
In-Reply-To: <1328117722.2446.262.camel@twins>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
	 <1327591185.2446.102.camel@twins>
	 <CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com>
	 <1328117722.2446.262.camel@twins>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>, paulmck <paulmck@linux.vnet.ibm.com>

On Wed, 2012-02-01 at 18:35 +0100, Peter Zijlstra wrote:
> On Sun, 2012-01-29 at 10:25 +0200, Gilad Ben-Yossef wrote:
> >=20
> > If this is of interest, I keep a list tracking global IPI and global
> > task schedulers sources in the core kernel here:
> > https://github.com/gby/linux/wiki.=20
>=20
> You can add synchronize_.*_expedited() to the list, it does its best to
> bash the entire machine in order to try and make RCU grace periods
> happen fast.

Also anything using stop_machine, such as module unload, cpu hot-unplug
and text_poke().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
