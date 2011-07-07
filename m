Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5960B9000C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 08:02:49 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 8bit
Date: Thu, 07 Jul 2011 08:02:44 -0400
From: mail@rsmogura.net
Subject: Re: Hugepages for shm page cache (defrag)
In-Reply-To: <m2pqlmy7z8.fsf@firstfloor.org>
References: <201107062131.01717.mail@smogura.eu>
 <m2pqlmy7z8.fsf@firstfloor.org>
Message-ID: <5be3df4081574f3d4e1e699f028549a7@rsmogura.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: =?UTF-8?Q?Rados=C5=82aw_Smogura?= <mail@smogura.eu>, linux-mm@kvack.org, aarcange@redhat.com

On Wed, 06 Jul 2011 22:28:59 -0700, Andi Kleen wrote:
> RadosA?aw Smogura <mail@smogura.eu> writes:
>
>> Hello,
>>
>> This is may first try with Linux patch, so please do not blame me 
>> too much.
>> Actually I started with small idea to add MAP_HUGTLB for /dev/shm 
>> but it grew
>> up in something more like support for huge pages in page cache, but 
>> according
>> to documentation to submit alpha-work too, I decided to send this.
>
> Shouldn't this be rather integrated with the normal transparent huge
> pages? It seems odd to develop parallel infrastructure.
>
> -Andi
It's not quite good to ask me about this, as I'm starting hacker, but I 
think it should be treated as counterpart for page cache, and actually I 
got few "collisions" with THP.

High level design will probably be the same (e.g. I use defrag_, THP 
uses collapse_ for creating huge page), but in contrast I try to operate 
on page cache, so in some way file system must be huge page aware (shm 
fs is not, as it can move page from page cache to swap cache - it may 
silently fragment de-fragmented areas).

I put some requirements for work, e. g. mapping file as huge should not 
affect previous or future, even fancy, non huge mappings, both callers 
should succeed and get this what they asked for.

Of course I think how to make it more "transparent" without need of 
file system support, but I suppose it may be dead-corner.

I still want to emphasise it's really alpha version.

Regards,
Radek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
