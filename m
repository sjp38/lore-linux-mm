Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 50A416006B4
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 21:03:01 -0400 (EDT)
Received: by pvc30 with SMTP id 30so2307529pvc.14
        for <linux-mm@kvack.org>; Mon, 19 Jul 2010 18:02:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201007192039.06670.agruen@suse.de>
References: <4C425273.5000702@gmail.com>
	<20100718060106.GA579@infradead.org>
	<4C42A10B.2080904@gmail.com>
	<201007192039.06670.agruen@suse.de>
Date: Tue, 20 Jul 2010 09:02:57 +0800
Message-ID: <AANLkTimh4UjM3LWPjBjMA5UGecQYyPSxIvJBInijAP-j@mail.gmail.com>
Subject: Re: [PATCH] fix return value for mb_cache_shrink_fn when nr_to_scan >
	0
From: shenghui <crosslonelyover@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andreas Gruenbacher <agruen@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Eric Sandeen <sandeen@redhat.com>, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-ext4 <linux-ext4@vger.kernel.org>, kernel-janitors <kernel-janitors@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

2010/7/20 Andreas Gruenbacher <agruen@suse.de>:
> On Sunday 18 July 2010 08:36:59 Wang Sheng-Hui wrote:
>> I regenerated the patch. Please check it.
>
> The logic for calculating how many objects to free is still wrong:
> mb_cache_shrink_fn returns the number of entries scaled by
> sysctl_vfs_cache_pressure / 100. =C2=A0It should also scale nr_to_scan by=
 the
> inverse of that. =C2=A0The sysctl_vfs_cache_pressure =3D=3D 0 case (never=
 scale) may
> require special attention.
>
> See dcache_shrinker() in fs/dcache.c.
>
> Thanks,
> Andreas
>

Sorry, I haven't found any special attention on
sysctl_vfs_cache_pressure =3D=3D 0 case or scale
nr_to_scan in fs/dcache.c

 900static int shrink_dcache_memory(int nr, gfp_t gfp_mask)
 901{
 902        if (nr) {
 903                if (!(gfp_mask & __GFP_FS))
 904                        return -1;
 905                prune_dcache(nr);
 906        }
 907        return (dentry_stat.nr_unused / 100) * sysctl_vfs_cache_pressur=
e;
 908}




--=20


Thanks and Best Regards,
shenghui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
