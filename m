Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 975796B005A
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 09:30:36 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so3714951obb.14
        for <linux-mm@kvack.org>; Fri, 01 Jun 2012 06:30:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1205311414090.2764@chino.kir.corp.google.com>
References: <20120523203433.340661918@linux.com>
	<20120523203505.599591201@linux.com>
	<alpine.DEB.2.00.1205311414090.2764@chino.kir.corp.google.com>
Date: Fri, 1 Jun 2012 22:30:35 +0900
Message-ID: <CAAmzW4MVADTVtTyj-wq2YU30pJm1Kf4odOHFnb4chaz1UZ9wsQ@mail.gmail.com>
Subject: Re: Common 01/22] [slob] Define page struct fields used in mm_types.h
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>

2012/6/1 David Rientjes <rientjes@google.com>:
> On Wed, 23 May 2012, Christoph Lameter wrote:
>
>> Define the fields used by slob in mm_types.h and use struct page instead
>> of struct slob_page in slob. This cleans up numerous of typecasts in slob.c and
>> makes readers aware of slob's use of page struct fields.
>>
>> [Also cleans up some bitrot in slob.c. The page struct field layout
>> in slob.c is an old layout and does not match the one in mm_types.h]
>>
>> Reviewed-by: Glauber Costa <gommer@parallels.com>
>> Signed-off-by: Christoph Lameter <cl@linux.com>
>
> Acked-by: David Rientjes <rientjes@google.com>
Reviewed-by: Joonsoo Kim <js1304@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
