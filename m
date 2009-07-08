Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BB1816B004D
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 18:45:09 -0400 (EDT)
Received: by qyk36 with SMTP id 36so4754709qyk.12
        for <linux-mm@kvack.org>; Wed, 08 Jul 2009 15:57:04 -0700 (PDT)
Message-ID: <4A55243B.8090001@codemonkey.ws>
Date: Wed, 08 Jul 2009 17:56:59 -0500
From: Anthony Liguori <anthony@codemonkey.ws>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/4] (Take 2): transcendent memory ("tmem") for Linux
References: <482d25af-01eb-4c2a-9b1d-bdaf4020ce88@default>
In-Reply-To: <482d25af-01eb-4c2a-9b1d-bdaf4020ce88@default>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, chris.mason@oracle.com, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Dan Magenheimer wrote:
> Tmem [PATCH 0/4] (Take 2): Transcendent memory
> Transcendent memory - Take 2
> Changes since take 1:
> 1) Patches can be applied serially; function names in diff (Rik van Riel)
> 2) Descriptions and diffstats for individual patches (Rik van Riel)
> 3) Restructure of tmem_ops to be more Linux-like (Jeremy Fitzhardinge)
> 4) Drop shared pools until security implications are understood (Pavel
>    Machek and Jeremy Fitzhardinge)
> 5) Documentation/transcendent-memory.txt added including API description
>    (see also below for API description).
> 
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> 
> Normal memory is directly addressable by the kernel, of a known
> normally-fixed size, synchronously accessible, and persistent (though
> not across a reboot).
> 
> What if there was a class of memory that is of unknown and dynamically
> variable size, is addressable only indirectly by the kernel, can be
> configured either as persistent or as "ephemeral" (meaning it will be
> around for awhile, but might disappear without warning), and is still
> fast enough to be synchronously accessible?

I have trouble mapping this to a VMM capable of overcommit without just 
coming back to CMM2.

In CMM2 parlance, ephemeral tmem pools is just normal kernel memory 
marked in the volatile state, no?

It seems to me that an architecture built around hinting would be more 
robust than having to use separate memory pools for this type of memory 
(especially since you are requiring a copy to/from the pool).

For instance, you can mark data DMA'd from disk (perhaps by read-ahead) 
as volatile without ever bringing it into the CPU cache.  With tmem, if 
you wanted to use a tmem pool for all of the page cache, you'd likely 
suffer significant overhead due to copying.

Regards,

Anthony Liguori

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
