Date: Wed, 8 Sep 2004 23:55:03 +0200
From: Diego Calleja <diegocg@teleline.es>
Subject: Re: swapping and the value of /proc/sys/vm/swappiness
Message-Id: <20040908235503.3f01523a.diegocg@teleline.es>
In-Reply-To: <36100000.1094677832@flay>
References: <5860000.1094664673@flay>
	<Pine.LNX.4.44.0409081403500.23362-100000@chimarrao.boston.redhat.com>
	<20040908215008.10a56e2b.diegocg@teleline.es>
	<36100000.1094677832@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: riel@redhat.com, raybry@sgi.com, marcelo.tosatti@cyclades.com, kernel@kolivas.org, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

El Wed, 08 Sep 2004 14:10:32 -0700 "Martin J. Bligh" <mbligh@aracnet.com> escribio:

> I really don't see any point in pushing the self-tuning of the kernel out
> into userspace. What are you hoping to achieve?

Well your own words explain it, I think. "it's all dependant on the workload",
which means that only the user knows what he is going to do with the machine
and that the kernel doesn't knows that, so the algoritms built in the kernel
may be "not perfect" in their auto-tuning job. The point would be to
be able to take decisions the kernel can't take because userspace would
know better how the system should behave, say stupids things like "I want
to have this set of tunables which make compile jobs 0.01% faster at 12:00
because at that time a cron job autocompiles cvs snapshots of some project,
and at 6:00 those jobs have already finished so at that time I want a set
of tunables optimized for my everyday desktop work which make everthing 0.01%
slower but the system feels a 5% more reponsive". (well, for that a shell script
is enought) Kernel however could try to adapt itself to those changes, and do
it well...I don't really know. This came to my mind when I was thinking about
irqbalance case, which was somewhat similar, I also remember a discussion
about a "ktuned" in the mailing lists...I guess it's a matter of coding it
and get some numbers :-/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
