Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8F9C3600802
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 21:04:48 -0400 (EDT)
Received: by pxi7 with SMTP id 7so2466798pxi.14
        for <linux-mm@kvack.org>; Mon, 19 Jul 2010 18:04:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTimh4UjM3LWPjBjMA5UGecQYyPSxIvJBInijAP-j@mail.gmail.com>
References: <4C425273.5000702@gmail.com>
	<20100718060106.GA579@infradead.org>
	<4C42A10B.2080904@gmail.com>
	<201007192039.06670.agruen@suse.de>
	<AANLkTimh4UjM3LWPjBjMA5UGecQYyPSxIvJBInijAP-j@mail.gmail.com>
Date: Tue, 20 Jul 2010 09:04:46 +0800
Message-ID: <AANLkTimBCrq8cPJrTSKiG_wbd1ppu0twTAMXeezJEZs3@mail.gmail.com>
Subject: Re: [PATCH] fix return value for mb_cache_shrink_fn when nr_to_scan >
	0
From: shenghui <crosslonelyover@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andreas Gruenbacher <agruen@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Eric Sandeen <sandeen@redhat.com>, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-ext4 <linux-ext4@vger.kernel.org>, kernel-janitors <kernel-janitors@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

2010/7/20 shenghui <crosslonelyover@gmail.com>:
> 2010/7/20 Andreas Gruenbacher <agruen@suse.de>:
>
> Sorry, I haven't found any special attention on
> sysctl_vfs_cache_pressure =3D=3D 0 case or scale
> nr_to_scan in fs/dcache.c
>
> =C2=A0900static int shrink_dcache_memory(int nr, gfp_t gfp_mask)
> =C2=A0901{
> =C2=A0902 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (nr) {
> =C2=A0903 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!(gf=
p_mask & __GFP_FS))
> =C2=A0904 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0return -1;
> =C2=A0905 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0prune_dc=
ache(nr);
> =C2=A0906 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0907 =C2=A0 =C2=A0 =C2=A0 =C2=A0return (dentry_stat.nr_unused / 100)=
 * sysctl_vfs_cache_pressure;
> =C2=A0908}
>

And for sysctl_vfs_cache_pressure =3D=3D 0 case, it's
enough to return 0 to indicate no cache entries left.



--=20


Thanks and Best Regards,
shenghui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
