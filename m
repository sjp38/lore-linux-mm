Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8H9BcLo003798
	for <linux-mm@kvack.org>; Mon, 17 Sep 2007 19:11:38 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8H9Bcdk2863204
	for <linux-mm@kvack.org>; Mon, 17 Sep 2007 19:11:38 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8H9BbYe026278
	for <linux-mm@kvack.org>; Mon, 17 Sep 2007 19:11:38 +1000
Message-ID: <46EE44C3.80508@linux.vnet.ibm.com>
Date: Mon, 17 Sep 2007 14:41:31 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: Userspace tools  (was Re: [PATCH][RESEND] maps: PSS(proportional
 set size) accounting in smaps)
References: <389996856.30386@ustc.edu.cn> <20070916235120.713c6102.akpm@linux-foundation.org> <46EE2802.1000007@linux.vnet.ibm.com> <20070917090057.GA2083@infradead.org>
In-Reply-To: <20070917090057.GA2083@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <wfg@mail.ustc.edu.cn>, John Berthels <jjberthels@gmail.com>, Denys Vlasenko <vda.linux@googlemail.com>, Matt Mackall <mpm@selenic.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:
> On Mon, Sep 17, 2007 at 12:38:50PM +0530, Balbir Singh wrote:
>> Andrew Morton wrote:
>>> On Mon, 17 Sep 2007 10:40:54 +0800 Fengguang Wu <wfg@mail.ustc.edu.cn> wrote:
>>>
>>>> Matt Mackall's pagemap/kpagemap and John Berthels's exmap can also do the job.
>>>> They are comprehensive tools. But for PSS, let's do it in the simple way. 
>>> right.  I'm rather reluctant to merge anything which could have been done from
>>> userspace via the maps2 interfaces.
>>>
>>> See, this is why I think the kernel needs a ./userspace-tools/ directory.  If
>>> we had that, you might have implemented this as a little proglet which parses
>>> the maps2 files.  But we don't have that, so you ended up doing it in-kernel.
>> Andrew, I second the userspace-tools idea. I would also add an FAQ in
>> that directory, explaining what problem each tool solves. I think your
>> page cache control program would be a great example of something to put
>> in there.
> 
> It's called the util-linux package.

I am looking at http://www.kernel.org/pub/linux/utils/util-linux/ and
the last release happened in September 2005. May be I am looking in
the wrong place.

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
