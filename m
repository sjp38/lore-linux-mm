Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp05.au.ibm.com (8.13.8/8.13.6) with ESMTP id kAB0vtjB8904916
	for <linux-mm@kvack.org>; Fri, 10 Nov 2006 23:57:55 -0100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0208e0.au.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAACxF7d231652
	for <linux-mm@kvack.org>; Fri, 10 Nov 2006 23:59:20 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAACtkLs006152
	for <linux-mm@kvack.org>; Fri, 10 Nov 2006 23:55:48 +1100
Message-ID: <455476C0.6010204@in.ibm.com>
Date: Fri, 10 Nov 2006 18:25:28 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [ckrm-tech] [RFC][PATCH 6/8] RSS controller shares allocation
References: <20061109193523.21437.86224.sendpatchset@balbir.in.ibm.com>	<20061109193619.21437.84173.sendpatchset@balbir.in.ibm.com> <45544240.80609@openvz.org> <45545429.7080903@in.ibm.com> <4554552E.8050300@openvz.org>
In-Reply-To: <4554552E.8050300@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelianov <xemul@openvz.org>
Cc: dev@openvz.org, ckrm-tech@lists.sourceforge.net, haveblue@us.ibm.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, rohitseth@google.com
List-ID: <linux-mm.kvack.org>

Pavel Emelianov wrote:
> [snip]
> 
>>>> +	for_each_child(child, res->rgroup) {
>>>> +		child_res = get_memctlr(child);
>>>> +		BUG_ON(!child_res);
>>>> +		recalc_and_propagate(child_res, res);
>>> Recursion? Won't it eat all the stack in case of a deep tree?
>> The depth of the hierarchy can be controlled. Recursion is needed
>> to do a DFS walk
> 
> That's another point against recursion - bad root can
> crash the kernel... If we are about to give container's
> users ability to make their own subtrees then we *must*
> avoid recursion. There's an algorithm that allows one
> to walk the tree like this w/o recursion.

Bad pointers are always bad, whether they are the root or
any other pointer. Tree traversal is a generic infrastructure issue
for any infrastructure that supports a hierarchy.

Are you talking about threaded trees? Yes, they can be traversed
without recursion. I need to recheck my DS reference to double
check.

> 
> [snip]
> 
>>> I didn't find where in this patches this callback is called.
>> It's a part of the resource groups infrastructure. It's been ported
>> on top of Paul Menage's containers patches. The code can be easily
>> adapted to work directly with containers instead of resource groups
>> if required.
> 
> 
> Could you please give me a link to the patch where this
> is called?

Please see

http://www.mail-archive.com/ckrm-tech@lists.sourceforge.net/msg03333.html

-- 

	Balbir Singh,
	Linux Technology Center,
	IBM Software Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
