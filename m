Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 851F96B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 09:58:36 -0400 (EDT)
Message-ID: <501A8784.1050708@parallels.com>
Date: Thu, 2 Aug 2012 17:58:28 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [9/9] Do slab aliasing call from common code
References: <20120731173620.432853182@linux.com> <20120731173638.649541860@linux.com> <501A2B34.9070804@parallels.com> <alpine.DEB.2.00.1208020857011.23049@router.home>
In-Reply-To: <alpine.DEB.2.00.1208020857011.23049@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

On 08/02/2012 05:57 PM, Christoph Lameter wrote:
> On Thu, 2 Aug 2012, Glauber Costa wrote:
> 
>> This one didn't apply for me. I used pekka's tree + your other 8 patches
>> (being careful about the 8th one). Maybe you need to refresh this as
>> well as your 8th patch ?
>>
>> I could go see where it conflicts, but I'd like to make sure I am
>> reviewing/testing the code exactly as you intended it to be.
> 
> Yea well it may be better to use yesterdays patchset instead.
> 
I've already saw it, and commented on it. Thanks Christoph!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
