Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 19BF76B0088
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 15:55:54 -0500 (EST)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Fri, 30 Nov 2012 13:55:53 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 1D2AAC40002
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:55:46 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qAUKtpDO347940
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:55:51 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qAUKtoSH002400
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:55:50 -0700
Message-ID: <50B91D54.2080507@linux.vnet.ibm.com>
Date: Fri, 30 Nov 2012 12:55:48 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: 32/64-bit NUMA consolidation behavior regresion
References: <50B6A66E.8030406@linux.vnet.ibm.com> <20121130204237.GH3873@htj.dyndns.org>
In-Reply-To: <20121130204237.GH3873@htj.dyndns.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Cody P Schafer <cody@linux.vnet.ibm.com>

On 11/30/2012 12:42 PM, Tejun Heo wrote:
> On Wed, Nov 28, 2012 at 04:03:58PM -0800, Dave Hansen wrote:
>> My system is just qemu booted with:
>>
>> -smp 8 -m 8192 -numa node,nodeid=0,cpus=0-3 -numa node,nodeid=1,cpus=4-7
>>
>> Watch the "PERCPU:" line early in boot, and you can see the "Embedded"
>> come and go with or without your patch:
>>
>> [    0.000000] PERCPU: Embedded 11 pages/cpu @f3000000 s30592 r0 d14464
>> vs
>> [    0.000000] PERCPU: 11 4K pages/cpu @f83fe000 s30592 r0 d14464
> ...
>> I don't have a fix handy because I'm working on the original problem,
>> but I just happened to run across this during a bisect.
> 
> Just tested 3.7-rc7 w/ qemu and it works as expected here.
> 
> Can you please boot with the following debug patch and report the boot
> message before and after?

Hi Tejun,

I just tested with 3.7-rc7 and I'm seeing the expected behavior now.
Looks like it got fixed along the way somewhere.  I was bisecting way
back in the 2.6.3x's.  Sorry of the noise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
