Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id m4686Nhi003317
	for <linux-mm@kvack.org>; Tue, 6 May 2008 18:06:23 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m468Aqdx133484
	for <linux-mm@kvack.org>; Tue, 6 May 2008 18:10:53 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4686gis004920
	for <linux-mm@kvack.org>; Tue, 6 May 2008 18:06:50 +1000
Message-ID: <48200FDF.7070408@linux.vnet.ibm.com>
Date: Tue, 06 May 2008 13:29:27 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 4/4] Add rlimit controller documentation
References: <20080503213726.3140.68845.sendpatchset@localhost.localdomain> <20080503213825.3140.4328.sendpatchset@localhost.localdomain> <20080505153509.da667caf.akpm@linux-foundation.org> <481FEF28.1000502@linux.vnet.ibm.com> <20080505225434.3f81828b.akpm@linux-foundation.org>
In-Reply-To: <20080505225434.3f81828b.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, rientjes@google.com, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Tue, 06 May 2008 11:09:52 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>>> Ho hum, I had to do rather a lot of guesswork here to try to understand
>>> your proposed overall design for this feature.  I'd prefer to hear about
>>> your design via more direct means.
>> Do you have any suggestions on how to do that better. Would you like
>> documentation to be the first patch in the series? I had sent out two RFC's
>> earlier and got comments and feedback from several people.
>>
> 
> I do like to see the overall what-i-am-setting-out-to-do description in
> there somewhere - sometimes a Docuemtation/ file is appropriate, other
> times do it via changelog.
> 

I think having documentation upfront does make sense in that case. I'll also try
and make the changelogs more verbose. I usually try to point to the previous
discussions in the introduction patch.

> But the first part of the review is reviewing whatever it is which you set
> out to achieve.  Once that's understood and sounds like a good idea then we
> can start looking at how you did it.
> 
> 

Yes, I agree.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
