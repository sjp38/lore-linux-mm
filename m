Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E8A366B004D
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 02:02:01 -0500 (EST)
Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id nAR71vqm011430
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 07:01:58 GMT
Received: from pwj17 (pwj17.prod.google.com [10.241.219.81])
	by spaceape7.eur.corp.google.com with ESMTP id nAR71pCn022893
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 23:01:54 -0800
Received: by pwj17 with SMTP id 17so1010743pwj.5
        for <linux-mm@kvack.org>; Thu, 26 Nov 2009 23:01:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091126113209.5A68.A69D9226@jp.fujitsu.com>
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>
	 <20091126113209.5A68.A69D9226@jp.fujitsu.com>
Date: Thu, 26 Nov 2009 23:01:51 -0800
Message-ID: <604427e00911262301tac7f55avedd44263fbabccc2@mail.gmail.com>
Subject: Re: memcg: slab control
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 25, 2009 at 6:35 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi
>
>> Hi,
>>
>> I wanted to see what the current ideas are concerning kernel memory
>> accounting as it relates to the memory controller. =A0Eventually we'll w=
ant
>> the ability to restrict cgroups to a hard slab limit. =A0That'll require
>> accounting to map slab allocations back to user tasks so that we can
>> enforce a policy based on the cgroup's aggregated slab usage similiar to
>> how the memory controller currently does for user memory.
>>
>> Is this currently being thought about within the memcg community? =A0We'=
d
>> like to start a discussion and get everybody's requirements and interest=
s
>> on the table and then become actively involved in the development of suc=
h
>> a feature.
>
> I don't think memory hard isolation is bad idea. however, slab restrictio=
n
> is too strange. some device use slab frequently, another someone use get_=
free_pages()
> directly. only slab restriction will not make expected result from admin =
view.
>
> Probably, we need to implement generic memory reservation framework. it m=
ihgt help
> implemnt rt-task memory reservation and userland oom manager.
>
> It is only my personal opinion...

Looks like the beancounters implementation counts both the kernel slab
objects as well as the
pages from get_free_pages(). But It relies the caller to pass down a
GFP flag indicating the page
or slab to be accountable or not. I am looking at the beancounters v5 at:

http://lkml.indiana.edu/hypermail/linux/kernel/0610.0/1719.html

I kind of like the idea to have a kernel memory controller instead of
kernel slab controller.
If we only count kernel slabs, do we need another mechanism to count
kernel allocations
directly from get_free_pages() ?

--Ying
>
>
> Thanks.
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
