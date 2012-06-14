Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 784E76B0069
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 12:04:05 -0400 (EDT)
Message-ID: <4FDA0ADB.2010508@parallels.com>
Date: Thu, 14 Jun 2012 20:01:31 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] make CFLGS_OFF_SLAB visible for all slabs
References: <1339676244-27967-1-git-send-email-glommer@parallels.com> <1339676244-27967-5-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1206141019010.32075@router.home>
In-Reply-To: <alpine.DEB.2.00.1206141019010.32075@router.home>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, devel@openvz.org, Pekka Enberg <penberg@cs.helsinki.fi>

On 06/14/2012 07:19 PM, Christoph Lameter wrote:
> On Thu, 14 Jun 2012, Glauber Costa wrote:
>
>> Since we're now moving towards a unified slab allocator interface,
>> make CFLGS_OFF_SLAB visible to all allocators, even though SLAB keeps
>> being its only users. Also, make the name consistent with the other
>> flags, that start with SLAB_xx.
>
> What is the significance of knowledge about internal slab structures (such
> as the CFGLFS_OFF_SLAB) outside of the allocators?


I want to mask that out in kmem-specific slab creation. Since I am 
copying the original flags, and that flag is embedded in the slab saved 
flags, it will be carried to the new slab if I don't mask it out.

Alternatively to this, I can tweak slab.c to always mask out this at the 
beginning of cache creation, if you so prefer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
