Date: Mon, 3 Oct 2005 06:33:04 -0700 (PDT)
From: David Lang <dlang@digitalinsight.com>
Subject: Re: [PATCH 00/07][RFC] i386: NUMA emulation
In-Reply-To: <aec7e5c30510030302u8186cfer642c7b9337613de@mail.gmail.com>
Message-ID: <Pine.LNX.4.62.0510030628150.11541@qynat.qvtvafvgr.pbz>
References: <20050930073232.10631.63786.sendpatchset@cherry.local><1128093825.6145.26.camel@localhost><aec7e5c30510021908la86daf9je0584fb0107f833a@mail.gmail.com><Pine.LNX.4.62.0510030031170.11095@qynat.qvtvafvgr.pbz>
 <aec7e5c30510030302u8186cfer642c7b9337613de@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus.damm@gmail.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, Magnus Damm <magnus@valinux.co.jp>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 3 Oct 2005, Magnus Damm wrote:

> Date: Mon, 3 Oct 2005 19:02:08 +0900
> From: Magnus Damm <magnus.damm@gmail.com>
> To: David Lang <david.lang@digitalinsight.com>
> Cc: Dave Hansen <haveblue@us.ibm.com>, Magnus Damm <magnus@valinux.co.jp>,
>     linux-mm <linux-mm@kvack.org>,
>     Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
> Subject: Re: [PATCH 00/07][RFC] i386: NUMA emulation
> 
> On 10/3/05, David Lang <david.lang@digitalinsight.com> wrote:
>> On Mon, 3 Oct 2005, Magnus Damm wrote:
>>
>>> On 10/1/05, Dave Hansen <haveblue@us.ibm.com> wrote:
>>>> On Fri, 2005-09-30 at 16:33 +0900, Magnus Damm wrote:
>>>>> These patches implement NUMA memory node emulation for regular i386 PC:s.
>>>>>
>>>>> NUMA emulation could be used to provide coarse-grained memory resource control
>>>>> using CPUSETS. Another use is as a test environment for NUMA memory code or
>>>>> CPUSETS using an i386 emulator such as QEMU.
>>>>
>>>> This patch set basically allows the "NUMA depends on SMP" dependency to
>>>> be removed.  I'm not sure this is the right approach.  There will likely
>>>> never be a real-world NUMA system without SMP.  So, this set would seem
>>>> to include some increased (#ifdef) complexity for supporting SMP && !
>>>> NUMA, which will likely never happen in the real world.
>>>
>>> Yes, this patch set removes "NUMA depends on SMP". It also adds some
>>> simple NUMA emulation code too, but I am sure you are aware of that!
>>> =)
>>>
>>> I agree that it is very unlikely to find a single-processor NUMA
>>> system in the real world. So yes, "[PATCH 02/07] i386: numa on
>>> non-smp" adds _some_ extra complexity. But because SMP is set when
>>> supporting more than one cpu, and NUMA is set when supporting more
>>> than one memory node, I see no reason why they should be dependent on
>>> each other. Except that they depend on each other today and breaking
>>> them loose will increase complexity a bit.
>>
>> hmm, observation from the peanut gallery, would it make sene to look at
>> useing the NUMA code on single proc machines that use PAE to access more
>> then 4G or ram on a 32 bit system?
>
> Hm, maybe? =) What would you like to accomplish by that?

if nothing else preferential use of 'local' (non PAE) memory over 'remote' 
(PAE) memory for programs, while still useing it all as needed.

this may be done already, but this type of difference between the access 
speed of different chunks of ram seems to be exactly the type of thing 
that the NUMA code solves the general case for. I'm thinking that it may 
end up simplifying things if the same general-purpose logic will work for 
the specific case of PAE instead of it being hard coded as a special case.

it also just struck me as the most obvious example of where a UP box could 
have a NUMA-like memory arrangement (and therefor a case to justify 
decoupling the SMP and NUMA options)

David Lang

> / magnus
>

-- 
There are two ways of constructing a software design. One way is to make it so simple that there are obviously no deficiencies. And the other way is to make it so complicated that there are no obvious deficiencies.
  -- C.A.R. Hoare

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
