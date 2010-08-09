Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 34A916B02A9
	for <linux-mm@kvack.org>; Mon,  9 Aug 2010 09:57:07 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o79DqH5b002029
	for <linux-mm@kvack.org>; Mon, 9 Aug 2010 07:52:17 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o79DusAo032940
	for <linux-mm@kvack.org>; Mon, 9 Aug 2010 07:57:01 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o79DurmL030687
	for <linux-mm@kvack.org>; Mon, 9 Aug 2010 07:56:53 -0600
Message-ID: <4C600923.3030401@austin.ibm.com>
Date: Mon, 09 Aug 2010 08:56:51 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/9] v4 Update the find_memory_block declaration
References: <4C581A6D.9030908@austin.ibm.com>	<4C581C99.8090201@austin.ibm.com> <20100805135944.97ecbaa4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100805135944.97ecbaa4.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On 08/04/2010 11:59 PM, KAMEZAWA Hiroyuki wrote:
> On Tue, 03 Aug 2010 08:41:45 -0500
> Nathan Fontenot <nfont@austin.ibm.com> wrote:
> 
>> Update the find_memory_block declaration to to take a struct mem_section *
>> so that it matches the definition.
>>
>> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Hmm...my mmotm-0727 has this definition in memory.h...
> 
> extern struct memory_block *find_memory_block(struct mem_section *);
> 
> What patch makes it unsigned long ?
> 

I was basing the patches on the latest mainline tree.  Looks like  can drop
this patch in the next version of the patchset.

-Nathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
