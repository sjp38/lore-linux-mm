Message-ID: <48213A66.5030502@bull.net>
Date: Wed, 07 May 2008 07:13:10 +0200
From: Nadia Derbey <Nadia.Derbey@bull.net>
MIME-Version: 1.0
Subject: Re: [PATCH 1/8] Scaling msgmni to the amount of lowmem
References: <20080211141646.948191000@bull.net>		<20080211141813.354484000@bull.net>	<12c511ca0804291328v2f0b87csd0f2cf3accc6ad00@mail.gmail.com>	<481EC917.6070808@bull.net> <1FE6DD409037234FAB833C420AA843EC014392F9@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC014392F9@orsmsx424.amr.corp.intel.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cmm@us.ibm.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Luck, Tony wrote:
>>Well, this printk had been suggested by somebody (sorry I don't remember 
>>who) when I first submitted the patch. Actually I think it might be 
>>useful for a sysadmin to be aware of a change in the msgmni value: we 
>>have the message not only at boot time, but also each time msgmni is 
>>recomputed because of a change in the amount of memory.
> 
> 
> If the message is directed at the system administrator, then it would
> be nice if there were some more meaningful way to show the namespace
> that is affected than just printing the hex address of the kernel structure.
> 
> As the sysadmin for my test systems, printing the hex address is mildly
> annoying ... I now have to add a new case to my scripts that look at
> dmesg output for unusual activity.
> 
> Is there some better "name for a namespace" than the address? Perhaps
> the process id of the process that instantiated the namespace???
> 

Unfortunately no when we are inside an ipc namespace, we don't have such 
interesting informations. But I agree with you, an address is not 
readable enough. I'll try to find a solution.

Regards,
Nadia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
