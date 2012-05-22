Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 9C14F6B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 10:28:08 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so14792534obb.14
        for <linux-mm@kvack.org>; Tue, 22 May 2012 07:28:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120518161928.116651208@linux.com>
References: <20120518161906.207356777@linux.com>
	<20120518161928.116651208@linux.com>
Date: Tue, 22 May 2012 23:28:07 +0900
Message-ID: <CAAmzW4Pfntt=6zcTqCriC2c9BhiyaVgRO9b-E5XSm1=kQ+S4jQ@mail.gmail.com>
Subject: Re: [RFC] Common code 02/12] [slab]: Use page struct fields instead
 of casting
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Alex Shi <alex.shi@intel.com>

2012/5/19 Christoph Lameter <cl@linux.com>:
> Add fields to the page struct so that it is properly documented that
> slab overlays the lru fields.
>
> This cleans up some casts in slab.
>
> Reviewed-by: Glauber Costa <glommer@parallels.com>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Reviewed-by: Joonsoo Kim <js1304@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
