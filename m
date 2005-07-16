Message-ID: <42D84E0B.8050703@anu.edu.au>
Date: Sat, 16 Jul 2005 10:00:11 +1000
From: David Singleton <David.Singleton@anu.edu.au>
Reply-To: David.Singleton@anu.edu.au
MIME-Version: 1.0
Subject: Re: [NUMA] Display and modify the memory policy of a process through
 /proc/<pid>/numa_policy
References: <20050715211210.GI15783@wotan.suse.de> <Pine.LNX.4.62.0507151413360.11563@schroedinger.engr.sgi.com> <20050715214700.GJ15783@wotan.suse.de> <Pine.LNX.4.62.0507151450570.11656@schroedinger.engr.sgi.com> <20050715220753.GK15783@wotan.suse.de> <Pine.LNX.4.62.0507151518580.12160@schroedinger.engr.sgi.com> <20050715223756.GL15783@wotan.suse.de> <Pine.LNX.4.62.0507151544310.12371@schroedinger.engr.sgi.com> <20050715225635.GM15783@wotan.suse.de> <Pine.LNX.4.62.0507151602390.12530@schroedinger.engr.sgi.com> <20050715234402.GN15783@wotan.suse.de>
In-Reply-To: <20050715234402.GN15783@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Paul Jackson <pj@sgi.com>, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
>>No it wont. If you know that you are going to start a process that must 
>>run on node 3 and know its going to use 2G but there is only 1G free 
>>then you may want to modify the policy of an existing huge process on 
>>node 3that is still allocating to go to node 2 that just happens to have 
>>free space.
> 
> I think you should leave that to the kernel.
> 

But the kernel doesn't know about these future requirements.
A batch scheduler does.

> 
>>>>A batch scheduler may anticipate memory shortages and redirect memory 
>>>>allocations in order to avoid page migration.
>>>
>>>I think that jobs more belongs to the kernel. After all we don't
>>>want to move half of our VM into your proprietary scheduler.
>>
>>Care to tell me which proprietary scheduler you are talking about? I was 
> 
> 
> That SGI batch scheduler with its incredibly long specification
> list you guys seem to want to mess up all interfaces
> for. If I can download source to it please supply an URL. 

I think SGI are just trying to facilitate users (like us) with our
own schedulers.

> 
> 
>>And you are now going to implement automatic page migration into the 
>>existing scheduler?
> 
> 
> Hmm? You mean the kernel CPU scheduler? Nobody is planning to add
> page migration to that.

Exactly.  Some of us think we can do a half decent job of manually
controlling page migration.  What is the harm in letting us "shoot
ourselves in the foot" trying?

-- 
--------------------------------------------------------------------------
                                     ANU Supercomputer Facility
    David.Singleton@anu.edu.au       and APAC National Facility
    Phone: +61 2 6125 4389           Leonard Huxley Bldg (No. 56)
    Fax:   +61 2 6125 8199           Australian National University
                                     Canberra, ACT, 0200, Australia
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
