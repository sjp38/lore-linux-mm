Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 421FF6B00C5
	for <linux-mm@kvack.org>; Mon,  4 May 2009 21:00:55 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so2290209yxh.26
        for <linux-mm@kvack.org>; Mon, 04 May 2009 18:00:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.1.10.0905041214160.15574@qirst.com>
References: <20090504163731.3675ea87@rwuerthntp>
	 <alpine.DEB.1.10.0905041214160.15574@qirst.com>
Date: Tue, 5 May 2009 10:00:54 +0900
Message-ID: <44c63dc40905041800j217f11c6yec7fe003fb820419@mail.gmail.com>
Subject: Re: [PATCH] alloc_vmap_area: fix memory leak
From: Minchan Kim <barrioskmc@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Ralph Wuerthner <ralphw@linux.vnet.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Nice catch!
Looks good to me.

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

On Tue, May 5, 2009 at 1:15 AM, Christoph Lameter <cl@linux.com> wrote:
>
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Thanks,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
