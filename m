From: David Lang <david.lang@digitalinsight.com>
In-Reply-To: <77150000.1128350759@[10.10.2.4]>
References: dlang@dlang.diginsite.com <Pine.LNX.4.62.0510030031170.11095@qynat.qvtvafvgr.pbz> <77150000.1128350759@[10.10.2.4]>
Date: Mon, 3 Oct 2005 07:49:41 -0700 (PDT)
Subject: Re: [PATCH 00/07][RFC] i386: NUMA emulation
In-Reply-To: <77150000.1128350759@[10.10.2.4]>
Message-ID: <Pine.LNX.4.62.0510030748470.11541@qynat.qvtvafvgr.pbz>
References: dlang@dlang.diginsite.com <Pine.LNX.4.62.0510030031170.11095@qynat.qvtvafvgr.pbz>
 <77150000.1128350759@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Magnus Damm <magnus.damm@gmail.com>, Dave Hansen <haveblue@us.ibm.com>, Magnus Damm <magnus@valinux.co.jp>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 3 Oct 2005, Martin J. Bligh wrote:

>>> I agree that it is very unlikely to find a single-processor NUMA
>>> system in the real world. So yes, "[PATCH 02/07] i386: numa on
>>> non-smp" adds _some_ extra complexity. But because SMP is set when
>>> supporting more than one cpu, and NUMA is set when supporting more
>>> than one memory node, I see no reason why they should be dependent on
>>> each other. Except that they depend on each other today and breaking
>>> them loose will increase complexity a bit.
>>
>> hmm, observation from the peanut gallery, would it make sene to look at
>> useing the NUMA code on single proc machines that use PAE to access
>> more then 4G or ram on a 32 bit system?
>
> 2 problems:
>
> 1) there aren't any ;-)
> 2) The memory is not physically differently separated from the CPUs, so
> it's not NUMA.

even though it's not physically differently seperated from the CPU(s) 
doesn't it's differing performance amount to the same thing?

David Lang

-- 
There are two ways of constructing a software design. One way is to make it so simple that there are obviously no deficiencies. And the other way is to make it so complicated that there are no obvious deficiencies.
  -- C.A.R. Hoare

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
