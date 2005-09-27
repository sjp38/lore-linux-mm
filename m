Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8RL108E016287
	for <linux-mm@kvack.org>; Tue, 27 Sep 2005 17:01:00 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8RL0jk6106124
	for <linux-mm@kvack.org>; Tue, 27 Sep 2005 17:01:00 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j8RL0jiD014312
	for <linux-mm@kvack.org>; Tue, 27 Sep 2005 17:00:45 -0400
Message-ID: <4339B2F6.1070806@austin.ibm.com>
Date: Tue, 27 Sep 2005 16:00:38 -0500
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: [PATCH 1/9] add defrag flags
References: <4338537E.8070603@austin.ibm.com>	<43385412.5080506@austin.ibm.com>	<21024267-29C3-4657-9C45-17D186EAD808@mac.com>	<1127780648.10315.12.camel@localhost>	<20050926224439.056eaf8d.pj@sgi.com>	<433991A0.7000803@austin.ibm.com> <20050927123055.0ad9c2b4.pj@sgi.com>
In-Reply-To: <20050927123055.0ad9c2b4.pj@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: haveblue@us.ibm.com, mrmacman_g4@mac.com, akpm@osdl.org, lhms-devel@lists.sourceforge.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, kravetz@us.ibm.com
List-ID: <linux-mm.kvack.org>

> Once this is merged with current Linux, which already has GFP_HARDWALL,
> I presume you will be back up to 21 bits, code and comment.

Looks like it.

> 
> As I noted in another message the "USER" and the comment in:
> 
> #define __GFP_USER	0x40000u /* User is a userspace user */
> 
> are a bit misleading now.  Perhaps GFP_EASYRCLM?
> 

A rose by any other name would smell as sweet -Romeo

A flag by any other name would work as well -Joel

There are problems with any name we would use.  I personally like __GFP_USER 
because it is mostly user memory, and nobody will accidently use it to label 
something that is not user memory.  Those who do use it for non-user memory will 
do so with more caution and ridicule.  This will keep it from expanding in use 
beyond its intent.

If we name it __GFP_EASYRCLM we then start getting into questions about what we 
mean by easy and somebody is going to  decide that their kernel memory is pretty 
easy to reclaim and mess things up.  Maybe we could call it 
__GPF_REALLYREALLYEASYRCLM to avoid confusion.

If there is a consensus from multiple people for me to go rename the flag 
__GFP_xxxxx then I'm not that attached to it and will.  But for now I'm going to 
leave it __GFP_USER.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
