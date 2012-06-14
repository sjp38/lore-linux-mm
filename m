Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 331AE6B0069
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 06:36:55 -0400 (EDT)
Message-ID: <4FD9BE30.4000005@parallels.com>
Date: Thu, 14 Jun 2012 14:34:24 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [19/20] Allocate kmem_cache structure in slab_common.c
References: <20120613152451.465596612@linux.com> <20120613152525.596813300@linux.com> <CAOJsxLE-7XCzbAi-M=sBkPymAj25yNGvAs6ea-ZyaEbDJo3+cA@mail.gmail.com>
In-Reply-To: <CAOJsxLE-7XCzbAi-M=sBkPymAj25yNGvAs6ea-ZyaEbDJo3+cA@mail.gmail.com>
Content-Type: multipart/mixed;
	boundary="------------010209040500010804000501"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

--------------010209040500010804000501
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit

On 06/14/2012 02:16 PM, Pekka Enberg wrote:
> On Wed, Jun 13, 2012 at 6:25 PM, Christoph Lameter<cl@linux.com>  wrote:
>> Move kmem_cache memory allocation and the checks for success out of the
>> slab allocators into the common code.
>>
>> Signed-off-by: Christoph Lameter<cl@linux.com>
>
> This patch seems to cause hard lockup on my laptop on boot.
>
> P.S. While bisecting this, I also saw some other oopses so I think
> this series needs some more testing before we can put it in
> linux-next...
Hi Pekka

Could you please test the following patch ?

This made Cristoph's series a lot more stable for me, it will at least 
allow us to know if this is the issue, or if you're seeing something else.

--------------010209040500010804000501
Content-Type: text/x-patch; name="0001-slab-fix-obj-size-calculation.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="0001-slab-fix-obj-size-calculation.patch"


--------------010209040500010804000501--
