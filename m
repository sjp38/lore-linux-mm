From: Joseph Ruscio <jruscio-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ do?
Date: Sat, 14 Mar 2009 10:11:11 -0700
Message-ID: <32D23C53-5407-4C7C-9F33-CA58C5BBF0E4@gmail.com>
References: <49B775B4.1040800@free.fr> <20090312145311.GC12390@us.ibm.com>
	<1236891719.32630.14.camel@bahia>
	<20090312212124.GA25019@us.ibm.com>
	<604427e00903122129y37ad791aq5fe7ef2552415da9@mail.gmail.com>
	<20090313053458.GA28833@us.ibm.com>
	<alpine.LFD.2.00.0903131018390.3940@localhost.localdomain>
	<20090313193500.GA2285@x200.localdomain>
	<alpine.LFD.2.00.0903131401070.3940@localhost.localdomain>
	<20090314002059.GA4167@x200.localdomain>
	<20090314082532.GB16436@elte.hu>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090314082532.GB16436-X9Un+BFzKDI@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: linux-mm.kvack.org


On Mar 14, 2009, at 1:25 AM, Ingo Molnar wrote:

> * Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
>> On Fri, Mar 13, 2009 at 02:01:50PM -0700, Linus Torvalds wrote:
>>>
>>>
>>> On Fri, 13 Mar 2009, Alexey Dobriyan wrote:
>>>>>
>>>>> Let's face it, we're not going to _ever_ checkpoint any
>>>>> kind of general case process. Just TCP makes that
>>>>> fundamentally impossible in the general case, and there
>>>>> are lots and lots of other cases too (just something as
>>>>> totally _trivial_ as all the files in the filesystem
>>>>> that don't get rolled back).
>>>>
>>>> What do you mean here? Unlinked files?
>>>
>>> Or modified files, or anything else. "External state" is a
>>> pretty damn wide net. It's not just TCP sequence numbers and
>>> another machine.
>>
>> I think (I think) you're seriously underestimating what's
>> doable with kernel C/R and what's already done.
>>
>> I was told (haven't seen it myself) that Oracle installations
>> and Counter Strike servers were moved between boxes just fine.
>>
>> They were run in specially prepared environment of course, but
>> still.
>
> That's the kind of stuff i'd like to see happen.
>
> Right now the main 'enterprise' approach to do
> migration/consolidation of server contexts is based on hardware
> virtualization - but that pushes runtime overhead to the native
> kernel and slows down the guest context as well - massively so.
>
> Before we've blinked twice it will be a 'required' enterprise
> feature and enterprise people will measure/benchmark Linux
> server performance in guest context primarily and we'll have a
> deep performance pit to dig ourselves out of.
>
> We can ignore that trend as uninteresting (it is uninteresting
> in a number of ways because it is partly driven by stupidity),
> or we can do something about it while still advancing the
> kernel.

I'd tend to echo these comments. I don't think you can underestimate  
how many workloads are stuck in VM's (or under consideration for such)  
mainly in order to containerize them and make them mobile. Right now  
VM's are the only hammer, so every virtualization scenario looks like  
a nail. As an extreme example, some of the National Labs are  
experimenting with VM's to checkpoint long-running jobs or live- 
migrate a part of a job off a machine throwing hardware errors (soon  
to fail). They're trying this approach even though VM's can add a  
significant overhead (in the I/O path), typically considered the third  
rail in HPC.

KVM is a step in the right direction, because we can now locate some  
number of VM's with a native workload, but the OpenVZ guys have shown  
that you can achieve much higher densities with an OS Virtualization  
container approach.

Joe
