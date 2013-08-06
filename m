Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id E4A736B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 16:45:13 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nfont@linux.vnet.ibm.com>;
	Wed, 7 Aug 2013 06:32:12 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 2D6253578053
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 06:45:07 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r76KTLfv7602452
	for <linux-mm@kvack.org>; Wed, 7 Aug 2013 06:29:27 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r76Kj0Ua005061
	for <linux-mm@kvack.org>; Wed, 7 Aug 2013 06:45:00 +1000
Message-ID: <52016047.5060903@linux.vnet.ibm.com>
Date: Tue, 06 Aug 2013 15:44:55 -0500
From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/8] Add all memory via sysfs probe interface at once
References: <51F01E06.6090800@linux.vnet.ibm.com> <51F01EFB.6070207@linux.vnet.ibm.com> <20130802023259.GC1680@concordia> <51FC04C2.70100@linux.vnet.ibm.com> <20130805031326.GB5347@concordia>
In-Reply-To: <20130805031326.GB5347@concordia>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <michael@ellerman.id.au>
Cc: linux-mm <linux-mm@kvack.org>, isimatu.yasuaki@jp.fujitsu.com, linuxppc-dev@lists.ozlabs.org, LKML <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 08/04/2013 10:13 PM, Michael Ellerman wrote:
> On Fri, Aug 02, 2013 at 02:13:06PM -0500, Nathan Fontenot wrote:
>> On 08/01/2013 09:32 PM, Michael Ellerman wrote:
>>> On Wed, Jul 24, 2013 at 01:37:47PM -0500, Nathan Fontenot wrote:
>>>> When doing memory hot add via the 'probe' interface in sysfs we do not
>>>> need to loop through and add memory one section at a time. I think this
>>>> was originally done for powerpc, but is not needed. This patch removes
>>>> the loop and just calls add_memory for all of the memory to be added.
>>>
>>> Looks like memory hot add is supported on ia64, x86, sh, powerpc and
>>> s390. Have you tested on any?
>>
>> I have tested on powerpc. I would love to say I tested on the other
>> platforms... but I haven't.  I should be able to get a x86 box to test
>> on but the other architectures may not be possible.
> 
> Is the rest of your series dependent on this patch? Or is it sort of
> incidental?
> 
> If possible it might be worth pulling this one out and sticking it in
> linux-next for a cycle to give people a chance to test it. Unless
> someone who knows the code well is comfortable with it.
> 

I am planning on pulling the first two patches and sending them out
separate from the patch set since they are really independent of the
rest of the patch series.

The remaining code I will send out for review and inclusion in
linux-next so it can have the proper test time as you mentioned.

-Nathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
