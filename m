Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6FD6E280281
	for <linux-mm@kvack.org>; Sat,  4 Jul 2015 16:09:26 -0400 (EDT)
Received: by qgeg89 with SMTP id g89so57483583qge.3
        for <linux-mm@kvack.org>; Sat, 04 Jul 2015 13:09:26 -0700 (PDT)
Received: from omr2.cc.vt.edu (omr2.cc.ipv6.vt.edu. [2607:b400:92:8400:0:33:fb76:806e])
        by mx.google.com with ESMTPS id z102si15232384qkg.53.2015.07.04.13.09.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 Jul 2015 13:09:25 -0700 (PDT)
Subject: Re: [PATCH 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory feature
In-Reply-To: Your message of "Fri, 03 Jul 2015 18:50:07 +0530."
             <1435929607-3435-1-git-send-email-pintu.k@samsung.com>
From: Valdis.Kletnieks@vt.edu
References: <1435929607-3435-1-git-send-email-pintu.k@samsung.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1436040527_26307P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Sat, 04 Jul 2015 16:08:47 -0400
Message-ID: <169308.1436040527@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Kumar <pintu.k@samsung.com>
Cc: corbet@lwn.net, akpm@linux-foundation.org, vbabka@suse.cz, gorcunov@openvz.org, mhocko@suse.cz, emunson@akamai.com, kirill.shutemov@linux.intel.com, standby24x7@gmail.com, hannes@cmpxchg.org, vdavydov@parallels.com, hughd@google.com, minchan@kernel.org, tj@kernel.org, rientjes@google.com, xypron.glpk@gmx.de, dzickus@redhat.com, prarit@redhat.com, ebiederm@xmission.com, rostedt@goodmis.org, uobergfe@redhat.com, paulmck@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, ddstreet@ieee.org, sasha.levin@oracle.com, koct9i@gmail.com, mgorman@suse.de, cj@linux.com, opensource.ganesh@gmail.com, vinmenon@codeaurora.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, cpgs@samsung.com, pintu_agarwal@yahoo.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, iqbal.ams@samsung.com

--==_Exmh_1436040527_26307P
Content-Type: text/plain; charset=us-ascii

On Fri, 03 Jul 2015 18:50:07 +0530, Pintu Kumar said:
> This patch provides 2 things:

> 2. Enable shrink_all_memory API in kernel with new CONFIG_SHRINK_MEMORY.
> Currently, shrink_all_memory function is used only during hibernation.
> With the new config we can make use of this API for non-hibernation case
> also without disturbing the hibernation case.

> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c

> @@ -3571,12 +3571,17 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
>  	struct reclaim_state reclaim_state;
>  	struct scan_control sc = {
>  		.nr_to_reclaim = nr_to_reclaim,
> +#ifdef CONFIG_SHRINK_MEMORY
> +		.gfp_mask = (GFP_HIGHUSER_MOVABLE | GFP_RECLAIM_MASK),
> +		.hibernation_mode = 0,
> +#else
>  		.gfp_mask = GFP_HIGHUSER_MOVABLE,
> +		.hibernation_mode = 1,
> +#endif


That looks like a bug just waiting to happen.  What happens if we
call an actual hibernation mode in a SHRINK_MEMORY=y kernel, and it finds
an extra gfp mask bit set, and hibernation_mode set to an unexpected value?

--==_Exmh_1436040527_26307P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVZg9TwdmEQWDXROgAQILcA/+LCKbaDVMteCnSoH+mFFsKFC7lzE73WES
Do2EfUI8iB9tCDeN7wLP0OHOP8WVO/jOcs6ltXVcGrkFA7aid7TrzZhkQQcU2fS9
iGWCwolNFXyQeMiJHimV94Ls1Vr1qJE1m0jVDAk4LuObht+adwWLvthSzaeVWF0P
QlsH7q1atNwB8yAm2G/Ck9LYXyGftpsJuq8PcNDJaOHDl5mzE7+zmG/owDqyKzoA
UrMqd7it89oNtsKpuMxl/sSrjz9/KUw5QsDxc32IsDXBsJA+onsVB5ZNWXihJLTO
eWg2ksJZhc5rl876YY3aq1hicsweSJf7cDTaVGO/q4J8thgzM2eo7OBbutKo6dW8
CbodQUq2IZqUv+nPwx3HQAC9LDSVo0Oy2Zr7T3clevMTfJQzQNrCHgr0F1W4kHkX
CDd5A6HHljmRuhUOXI+XIZ4njBK7ioHR2AV+GAmhppmTZE+ztZBPIUdo7toocoTW
755EiRI94vgp8t5sVGVV3KGji+VUnN3CluKlP1MtIvHxYM2ecZFOnhDkGfumlXeI
bJiIw7kJLySc+SxAlnPu83D6ypRMTOl9yoURzM4Bm2DDD6JlDrdniBj3b5UF316J
/JHu0VG49HoFl1ahqZpqk8+fyJm7avW7C9+PAr5tC8+/ZkdfLM0tkOcmfOLhvZxy
FVnyFbo1ZHw=
=fhxL
-----END PGP SIGNATURE-----

--==_Exmh_1436040527_26307P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
