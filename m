Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l1JAe0rf162896
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 21:40:00 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1JARfsB055646
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 21:27:41 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1JAOBsG025908
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 21:24:11 +1100
Message-ID: <45D97AC7.2000903@in.ibm.com>
Date: Mon, 19 Feb 2007 15:54:07 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [ckrm-tech] [RFC][PATCH][0/4] Memory controller (RSS Control)
References: <20070219065019.3626.33947.sendpatchset@balbir-laptop>	<20070219005441.7fa0eccc.akpm@linux-foundation.org> <6599ad830702190106m3f391de4x170326fef2e4872@mail.gmail.com> <45D972CC.2010702@sw.ru>
In-Reply-To: <45D972CC.2010702@sw.ru>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kirill Korotaev <dev@sw.ru>
Cc: Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, xemul@sw.ru, linux-kernel@vger.kernel.org, linux-mm@kvack.org, svaidy@linux.vnet.ibm.com, devel@openvz.org
List-ID: <linux-mm.kvack.org>

Kirill Korotaev wrote:
>> On 2/19/07, Andrew Morton <akpm@linux-foundation.org> wrote:
>>
>>> Alas, I fear this might have quite bad worst-case behaviour.  One small
>>> container which is under constant memory pressure will churn the
>>> system-wide LRUs like mad, and will consume rather a lot of system time.
>>> So it's a point at which container A can deleteriously affect things which
>>> are running in other containers, which is exactly what we're supposed to
>>> not do.
>>
>> I think it's OK for a container to consume lots of system time during
>> reclaim, as long as we can account that time to the container involved
>> (i.e. if it's done during direct reclaim rather than by something like
>> kswapd).
> hmm, is it ok to scan 100Gb of RAM for 10MB RAM container?
> in UBC patch set we used page beancounters to track containter pages.
> This allows to make efficient scan contoler and reclamation.
> 
> Thanks,
> Kirill

Hi, Kirill,

Yes, that's a problem, but I think it's a problem that can be solved
in steps. First step, add reclaim. Second step, optimize reclaim.

-- 
	Warm Regards,
	Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
