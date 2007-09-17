Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8H79at1005351
	for <linux-mm@kvack.org>; Mon, 17 Sep 2007 17:09:36 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8H7D95F287888
	for <linux-mm@kvack.org>; Mon, 17 Sep 2007 17:13:10 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8H79J5i025558
	for <linux-mm@kvack.org>; Mon, 17 Sep 2007 17:09:19 +1000
Message-ID: <46EE2802.1000007@linux.vnet.ibm.com>
Date: Mon, 17 Sep 2007 12:38:50 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Userspace tools  (was Re: [PATCH][RESEND] maps: PSS(proportional
 set size) accounting in smaps)
References: <389996856.30386@ustc.edu.cn> <20070916235120.713c6102.akpm@linux-foundation.org>
In-Reply-To: <20070916235120.713c6102.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Fengguang Wu <wfg@mail.ustc.edu.cn>, John Berthels <jjberthels@gmail.com>, Denys Vlasenko <vda.linux@googlemail.com>, Matt Mackall <mpm@selenic.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Mon, 17 Sep 2007 10:40:54 +0800 Fengguang Wu <wfg@mail.ustc.edu.cn> wrote:
> 
>> Matt Mackall's pagemap/kpagemap and John Berthels's exmap can also do the job.
>> They are comprehensive tools. But for PSS, let's do it in the simple way. 
> 
> right.  I'm rather reluctant to merge anything which could have been done from
> userspace via the maps2 interfaces.
> 
> See, this is why I think the kernel needs a ./userspace-tools/ directory.  If
> we had that, you might have implemented this as a little proglet which parses
> the maps2 files.  But we don't have that, so you ended up doing it in-kernel.

Andrew, I second the userspace-tools idea. I would also add an FAQ in
that directory, explaining what problem each tool solves. I think your
page cache control program would be a great example of something to put
in there.

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
