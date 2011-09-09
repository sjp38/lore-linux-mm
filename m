Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4DF936B018B
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 19:03:26 -0400 (EDT)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Fri, 9 Sep 2011 19:01:13 -0400
Subject: Re: [PATCH -v2 -mm] add extra free kbytes tunable
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CAFE00218@USINDEVS02.corp.hds.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>, "riel@redhat.com" <riel@redhat.com>
Cc: Satoru Moriya <smoriya@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hughd@google.com" <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On 09/01/2011 03:26 PM, Rik van Riel wrote:

> @@ -5123,6 +5135,7 @@ static void setup_per_zone_lowmem_reserve(void)
>  void setup_per_zone_wmarks(void)
>  {
>  	unsigned long pages_min =3D min_free_kbytes >> (PAGE_SHIFT - 10);
> +	unsigned long pages_low =3D extra_free_kbytes >> (PAGE_SHIFT - 10);

I think pages_extra is better name for this variable because pages_low is
calculated like following.

pages_low =3D pages_min + "pages_extra" + (pages_min >> 2)

>  	unsigned long lowmem_pages =3D 0;
>  	struct zone *zone;
>  	unsigned long flags;
> @@ -5134,11 +5147,14 @@ void setup_per_zone_wmarks(void)
>  	}
> =20
>  	for_each_zone(zone) {
> -		u64 tmp;
> +		u64 min, low;

Same as above.

Thanks,
Satoru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
