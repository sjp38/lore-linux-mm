Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 359026B005D
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 10:47:26 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Sat, 29 Sep 2012 00:45:21 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q8SEbgtY37027916
	for <linux-mm@kvack.org>; Sat, 29 Sep 2012 00:37:43 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q8SElHV9031912
	for <linux-mm@kvack.org>; Sat, 29 Sep 2012 00:47:18 +1000
Message-ID: <5065B84F.6060204@linux.vnet.ibm.com>
Date: Fri, 28 Sep 2012 20:16:39 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] CPU hotplug, writeback: Don't call writeback_set_ratelimit()
 too often during hotplug
References: <20120924102324.GA22303@aftab.osrc.amd.com> <20120924142305.GD12264@quack.suse.cz> <20120924143609.GH22303@aftab.osrc.amd.com> <20120924201650.6574af64.conny.seidel@amd.com> <20120924181927.GA25762@aftab.osrc.amd.com> <5060AB0E.3070809@linux.vnet.ibm.com> <5060C714.8030606@linux.vnet.ibm.com> <20120928122719.GA3067@localhost>
In-Reply-To: <20120928122719.GA3067@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Borislav Petkov <bp@amd64.org>, Conny Seidel <conny.seidel@amd.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>

On 09/28/2012 05:57 PM, Fengguang Wu wrote:
> On Tue, Sep 25, 2012 at 02:18:20AM +0530, Srivatsa S. Bhat wrote:
>>
>> From: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
>>
>> The CPU hotplug callback related to writeback calls writeback_set_ratelimit()
>> during every state change in the hotplug sequence. This is unnecessary
>> since num_online_cpus() changes only once during the entire hotplug operation.
>>
>> So invoke the function only once per hotplug, thereby avoiding the
>> unnecessary repetition of those costly calculations.
>>
>> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
>> ---
> 
> Looks good to me. I'll include it in the writeback tree.
> 

Great, thanks!
 
Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
