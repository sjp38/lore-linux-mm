Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 32E68900149
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 03:09:33 -0400 (EDT)
Received: by wwi36 with SMTP id 36so1633270wwi.26
        for <linux-mm@kvack.org>; Wed, 05 Oct 2011 00:09:30 -0700 (PDT)
Subject: Re: [RFCv3][PATCH 4/4] show page size in /proc/$pid/numa_maps
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1110042344250.16359@chino.kir.corp.google.com>
References: <20111001000856.DD623081@kernel>
	 <20111001000900.BD9248B8@kernel>
	 <alpine.DEB.2.00.1110042344250.16359@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 05 Oct 2011 09:09:24 +0200
Message-ID: <1317798564.3099.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, James.Bottomley@hansenpartnership.com, hpa@zytor.com

Le mardi 04 octobre 2011 A  23:50 -0700, David Rientjes a A(C)crit :

> This would be great if all the /proc/pid/numa_maps consumers were human, 
> but unfortuantely that's not the case.  
> 
> I understand that this patchset was probably the result of me asking for 
> the pagesize= to be specified in each line and using pagesize=4K and 
> pagesize=2M as examples, but that exact usage is probably not what we 
> want.
> 
> As long as there are scripts that go through and read this information 
> (we have some internally), expressing them with differing units just makes 
> it more difficult to parse.  I'd rather them just be the byte count.
> 
> That way, 1G pages would just show pagesize=1073741824.  I don't think 
> that's too long and is much easier to parse systematically.
> 

Hmm... Thats sounds strange.

Are you saying you cant change your scripts [But you'll have to anyway
to parse pagesize=] ?

I routinely use "cat /proc/xxx/numa_maps", and am stuck when a kernel
displays nothing (it happened on some debian released kernels)

Seeing pagesize=1GB is slightly better for human, and not that hard to
parse for a program.

By the way, "pagesize=4KiB" are just noise if you ask me, thats the
default PAGE_SIZE. This also breaks old scripts :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
