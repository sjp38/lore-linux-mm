Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 947B16B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 11:34:30 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so5895925qcs.14
        for <linux-mm@kvack.org>; Tue, 22 May 2012 08:34:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FBA0A5F.9000508@parallels.com>
References: <20120518161906.207356777@linux.com>
	<20120518161929.835778283@linux.com>
	<4FBA0A5F.9000508@parallels.com>
Date: Wed, 23 May 2012 00:34:29 +0900
Message-ID: <CAAmzW4NuisEXnoqyOJLCho0JxF3FK7=ypFoQWRPudZDEJ9S_Yg@mail.gmail.com>
Subject: Re: [RFC] Common code 05/12] slabs: Common definition for boot state
 of the slab allocators
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Alex Shi <alex.shi@intel.com>

2012/5/21 Glauber Costa <glommer@parallels.com>:
> On 05/18/2012 08:19 PM, Christoph Lameter wrote:
>>
>> All allocators have some sort of support for the bootstrap status.
>>
>> Setup a common definition for the boot states and make all slab
>> allocators use that definition.
>>
>> Signed-off-by: Christoph Lameter<cl@linux.com>
>
> Reviewed-by: Glauber Costa <glommer@parallels.com>
Reviewed-by: Joonsoo Kim <js1304@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
