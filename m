Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 72C9D6B13F0
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 04:42:26 -0500 (EST)
Received: by yhoo22 with SMTP id o22so1271325yho.14
        for <linux-mm@kvack.org>; Thu, 02 Feb 2012 01:42:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1328119072.2446.264.camel@twins>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
	<1327591185.2446.102.camel@twins>
	<CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com>
	<1328117722.2446.262.camel@twins>
	<1328119072.2446.264.camel@twins>
Date: Thu, 2 Feb 2012 11:42:25 +0200
Message-ID: <CAOtvUMcXjKFKiy1VQPz7WofFaxZMTTDBo-pKwGhVZerht=KCTg@mail.gmail.com>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>, paulmck <paulmck@linux.vnet.ibm.com>

On Wed, Feb 1, 2012 at 7:57 PM, Peter Zijlstra <peterz@infradead.org> wrote=
:
> On Wed, 2012-02-01 at 18:35 +0100, Peter Zijlstra wrote:
>> On Sun, 2012-01-29 at 10:25 +0200, Gilad Ben-Yossef wrote:
>> >
>> > If this is of interest, I keep a list tracking global IPI and global
>> > task schedulers sources in the core kernel here:
>> > https://github.com/gby/linux/wiki.
>>
>> You can add synchronize_.*_expedited() to the list, it does its best to
>> bash the entire machine in order to try and make RCU grace periods
>> happen fast.
>
> Also anything using stop_machine, such as module unload, cpu hot-unplug
> and text_poke().

Thanks! I've added it to the list together with the clocksource
watchdog, which is registering
a timer on each cpu in a cyclinc fashion.

Gilad


--=20
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
=A0-- Jean-Baptiste Queru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
