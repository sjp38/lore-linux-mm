Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F14E6B025F
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 06:17:40 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id z142so10297293itc.6
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 03:17:40 -0800 (PST)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id i81si3217244iof.207.2017.12.07.03.17.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 03:17:39 -0800 (PST)
Date: Thu, 7 Dec 2017 05:17:37 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slab: Merge adjacent debug sections
In-Reply-To: <1512641932-5221-1-git-send-email-geert+renesas@glider.be>
Message-ID: <alpine.DEB.2.20.1712070515490.7218@nuc-kabylake>
References: <1512641932-5221-1-git-send-email-geert+renesas@glider.be>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert+renesas@glider.be>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 7 Dec 2017, Geert Uytterhoeven wrote:

> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1569,9 +1569,6 @@ static void dump_line(char *data, int offset, int limit)
>  		}
>  	}
>  }
> -#endif
> -
> -#if DEBUG


Hmmm... This may match at other places. Also there are a lot of #ifdef
DEBUG / #else in that section of the code. Maybe better leave as is? Or
generally rework this into a single #ifdef DEBUG section with all the
debugging code in it and an #else section with all the empty functions.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
