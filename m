Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 20F1D6B009D
	for <linux-mm@kvack.org>; Wed, 29 May 2013 01:40:08 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 29 May 2013 15:31:23 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id BBFD42CE8052
	for <linux-mm@kvack.org>; Wed, 29 May 2013 15:39:58 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4T5PfEh25493566
	for <linux-mm@kvack.org>; Wed, 29 May 2013 15:25:42 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4T5duoq028551
	for <linux-mm@kvack.org>; Wed, 29 May 2013 15:39:57 +1000
Message-ID: <51A593F1.5090200@linux.vnet.ibm.com>
Date: Wed, 29 May 2013 11:06:49 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v2 00/15][Sorted-buddy] mm: Memory Power Management
References: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com> <5170D781.3000102@gmail.com> <5170EE4F.9030908@linux.vnet.ibm.com> <51A50EC4.4090108@ubuntu.com>
In-Reply-To: <51A50EC4.4090108@ubuntu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Phillip Susi <psusi@ubuntu.com>
Cc: Simon Jeons <simon.jeons@gmail.com>, akpm@linux-foundation.org, mgorman@suse.de, matthew.garrett@nebula.com, dave@sr71.net, rientjes@google.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, wujianguo@huawei.com, kmpark@infradead.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/29/2013 01:38 AM, Phillip Susi wrote:
> 
> On 4/19/2013 3:12 AM, Srivatsa S. Bhat wrote:
>> But going further, as I had mentioned in my TODO list, we can be
>> smarter than this while doing compaction to evacuate memory regions
>> - we can choose to migrate only the active pages, and leave the
>> inactive pages alone. Because, the goal is to actually consolidate
>> the *references* and not necessarily the *allocations* themselves.
> 
> That would help with keeping references compact to allow use of the
> low power states, but it would also be nice to keep allocations
> compact, and completely power off a bank of ram with no allocations.
> 

That is a very good point, thanks! But one of the differences we have to
keep in mind is that powering off a bank requires intervention from the
OS (ie., OS should initiate the power-off, because we lose the contents
on power-off) whereas going to lower power states can be mostly done
automatically by the hardware (because it is content-preserving).

But powering-off unused banks of RAM (using techniques such as PASR -
Partial Array Self Refresh) can give us more power-savings than just
entering lower power states. So yes, keeping allocations consolidated
has that additional advantage. And the sorted-buddy design of the page
allocator helps us achieve that.

Thanks a lot for your inputs, Phillip!

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
