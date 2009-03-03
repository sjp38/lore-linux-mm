Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 761EB6B00B0
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 11:17:40 -0500 (EST)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.1/8.13.1) with ESMTP id n23GHaG3017948
	for <linux-mm@kvack.org>; Tue, 3 Mar 2009 16:17:36 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n23GHa1O2269404
	for <linux-mm@kvack.org>; Tue, 3 Mar 2009 17:17:36 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n23GHaos012358
	for <linux-mm@kvack.org>; Tue, 3 Mar 2009 17:17:36 +0100
Message-ID: <49AD581F.2090903@free.fr>
Date: Tue, 03 Mar 2009 17:17:35 +0100
From: Cedric Le Goater <legoater@free.fr>
MIME-Version: 1.0
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
 do?
References: <1234467035.3243.538.camel@calx>	<20090212114207.e1c2de82.akpm@linux-foundation.org>	<1234475483.30155.194.camel@nimitz>	<20090212141014.2cd3d54d.akpm@linux-foundation.org>	<1234479845.30155.220.camel@nimitz>	<20090226162755.GB1456@x200.localdomain>	<20090226173302.GB29439@elte.hu>	<20090226223112.GA2939@x200.localdomain>	<20090301013304.GA2428@x200.localdomain>	<20090301200231.GA25276@us.ibm.com> <20090301205659.GA7276@x200.localdomain>
In-Reply-To: <20090301205659.GA7276@x200.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, mpm@selenic.com, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, tglx@linutronix.de, viro@zeniv.linux.org.uk, hpa@zytor.com, Ingo Molnar <mingo@elte.hu>, torvalds@linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>


>> 1. cap_sys_admin check is unfortunate.  In discussions about Oren's
>> patchset we've agreed that not having that check from the outset forces
>> us to consider security with each new patch and feature, which is a good
>> thing.
> 
> Removing CAP_SYS_ADMIN on restore?

we've kept the capabilities in our patchset but the user tools doing checkpoint
and restart are setcap'ed appropriately to be able to do different things like : 
	
	clone() the namespaces
	mount /dev/mqueue
	interact with net_ns
	etc.

at restart, the task are restarted through execve() so they loose their 
capabilities automatically.

but I think we could drop the CAP_SYS_ADMIN tests for some namespaces,
uts and ipc are good candidates. I guess network should require some 
privilege.  

C.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
