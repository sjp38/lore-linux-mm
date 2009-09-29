Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A03C16B005A
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 09:04:14 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.1/8.13.1) with ESMTP id n8TDTUBK013018
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 13:29:30 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8TDTToa3276900
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 15:29:29 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8TDTSiX031863
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 15:29:28 +0200
Message-ID: <4AC20BB8.4070509@free.fr>
Date: Tue, 29 Sep 2009 15:29:28 +0200
From: Daniel Lezcano <daniel.lezcano@free.fr>
MIME-Version: 1.0
Subject: Re: [PATCH 00/80] Kernel based checkpoint/restart [v18]
References: <1253749920-18673-1-git-send-email-orenl@librato.com>	<20090924154139.2a7dd5ec.akpm@linux-foundation.org> <20090928163704.GA3327@us.ibm.com>
In-Reply-To: <20090928163704.GA3327@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu, torvalds@linux-foundation.org, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

Serge E. Hallyn wrote:
> Quoting Andrew Morton (akpm@linux-foundation.org):
>   
>> On Wed, 23 Sep 2009 19:50:40 -0400
>> Oren Laadan <orenl@librato.com> wrote:
>>     
>>> Q: What about namespaces ?
>>> A: Currrently, UTS and IPC namespaces are restored. They demonstrate
>>>    how namespaces are handled. More to come.
>>>       
>> Will this new code muck up the kernel?
>>     

[ cut ]
> For network namespaces i think it's clearer that a wrapper
> program should set up the network for the restarted init task,
> while the usrspace code should recreate any private network
> namespaces and veth's which were created by the application.
> But it still needs discussion.
>   
Ok for the restart, but for the checkpoint, how do you access the 
network setup from a process which belongs to another namespace context ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
