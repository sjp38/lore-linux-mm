Date: Wed, 08 Sep 2004 15:20:42 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: swapping and the value of /proc/sys/vm/swappiness
Message-ID: <50520000.1094682042@flay>
In-Reply-To: <20040908235503.3f01523a.diegocg@teleline.es>
References: <5860000.1094664673@flay><Pine.LNX.4.44.0409081403500.23362-100000@chimarrao.boston.redhat.com><20040908215008.10a56e2b.diegocg@teleline.es><36100000.1094677832@flay> <20040908235503.3f01523a.diegocg@teleline.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Diego Calleja <diegocg@teleline.es>
Cc: riel@redhat.com, raybry@sgi.com, marcelo.tosatti@cyclades.com, kernel@kolivas.org, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

>> I really don't see any point in pushing the self-tuning of the kernel out
>> into userspace. What are you hoping to achieve?
> 
> Well your own words explain it, I think. "it's all dependant on the workload",
> which means that only the user knows what he is going to do with the machine
> and that the kernel doesn't knows that, so the algoritms built in the kernel
> may be "not perfect" in their auto-tuning job. The point would be to
> be able to take decisions the kernel can't take because userspace would
> know better how the system should behave, say stupids things like "I want
> to have this set of tunables which make compile jobs 0.01% faster at 12:00
> because at that time a cron job autocompiles cvs snapshots of some project,
> and at 6:00 those jobs have already finished so at that time I want a set
> of tunables optimized for my everyday desktop work which make everthing 0.01%
> slower but the system feels a 5% more reponsive". (well, for that a shell script
> is enought) Kernel however could try to adapt itself to those changes, and do
> it well...I don't really know. This came to my mind when I was thinking about
> irqbalance case, which was somewhat similar, I also remember a discussion
> about a "ktuned" in the mailing lists...I guess it's a matter of coding it
> and get some numbers :-/

Oh, I see what you mean. I think we're much better off sticking the mechanism
for autotuning stuff in the kernel - if we want to feed in policy from 
userspace (which 99.9% of people will never do), it can be through such
things as /proc/sys/vm/swapiness ... that could just fix them statically
if people insisted on such things. 

Having the kernel do something sensible by default is what we aim for ...
overrides still are possible if the sysadmin really thinks they're smarter ;-)

M.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
