References: <413CB661.6030303@sgi.com> <cone.1094512172.450816.6110.502@pc.kolivas.org> <20040906162740.54a5d6c9.akpm@osdl.org> <cone.1094513660.210107.6110.502@pc.kolivas.org> <20040907000304.GA8083@logos.cnet>
Message-ID: <cone.1094520855.843610.6110.502@pc.kolivas.org>
From: Con Kolivas <kernel@kolivas.org>
Subject: Re: swapping and the value of /proc/sys/vm/swappiness
Date: Tue, 07 Sep 2004 11:34:15 +1000
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset="US-ASCII"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Andrew Morton <akpm@osdl.org>, raybry@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, piggin@cyberone.com.au, mbligh@aracnet.com
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti writes:

> On Tue, Sep 07, 2004 at 09:34:20AM +1000, Con Kolivas wrote:
>> Andrew Morton writes:
>> 
>> >Con Kolivas <kernel@kolivas.org> wrote:
>> >>
>> >>> A scan of the change logs for swappiness related changes shows nothing 
>> >>that > might explain these changes.  My question is:  "Is this change in 
>> >> behavior
>> >> > deliberate, or just a side effect of other changes that were made in 
>> >> the vm?" > and "What kind of swappiness behavior might I expect to find 
>> >> in future kernels?".
>> >>
>> >> The change was not deliberate but there have been some other people 
>> >> report significant changes in the swappiness behaviour as well (see 
>> >> archives). It has usually been of the increased swapping variety lately. 
>> >> It has been annoying enough to the bleeding edge desktop users for a 
>> >> swag of out-of-tree hacks to start appearing (like mine).
>> >
>> >All of which is largely wasted effort.  It would be much more useful to get
>> >down and identify which patch actually caused the behavioural change.
>> 
>> I don't disagree. Is there anyone who has the time and is willing to do the 
>> regression testing? This is a general appeal to the mailing list.
> 
> Hi kernel fellows,
> 
> I volunteer. I'll try something tomorrow to compare swappiness of older kernels like  
> 2.6.5 and 2.6.6, which were fine on SGI's Altix tests, up to current newer kernels 
> (on small memory boxes of course).
> 
> Someone needs to write a vmstat-like tool to parse /proc/vmstat. 
> The statistics in there allows us to watch the behaviour of VM
> page reclaim code.
> 
> Con, if you could compile a list of reports we would be very grateful.

Apart from lots of "soft" reports I've been getting, the most obvious one 
recently on the mailing list is this: 

http://marc.theaimsgroup.com/?l=linux-kernel&m=109237941331221&w=2

and no, I'm not referring to this thread because he tried one of my patches; 
that's an old patch that I'm not even pushing any more.

Cheers,
Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
