Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 67D1D6B0071
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 06:15:25 -0500 (EST)
Received: by qyk4 with SMTP id 4so703554qyk.8
        for <linux-mm@kvack.org>; Thu, 11 Feb 2010 03:15:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201002111546.35036.knikanth@suse.de>
References: <201002091659.27037.knikanth@suse.de>
	 <20100211051341.GA13967@localhost>
	 <201002111304.54742.knikanth@suse.de>
	 <201002111546.35036.knikanth@suse.de>
Date: Thu, 11 Feb 2010 16:45:24 +0530
Message-ID: <d24465cb1002110315x4af18888na55aa8d61478e094@mail.gmail.com>
Subject: Re: [PATCH v2] Make VM_MAX_READAHEAD a kernel parameter
From: Ankit Jain <radical@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Jens Axboe <jens.axboe@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> +static int __init readahead(char *str)
> +{
> + =A0 =A0 =A0 if (!str)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 vm_max_readahead_kb =3D memparse(str, &str) / 1024ULL;

Just wondering, shouldn't you check whether the str had a valid value
[memparse (str, &next); next > str ..] and if it didn't, then use the
DEFAULT_VM_MAX_READAHEAD ? Otherwise, incase of a invalid
value, the readahead value will become zero.

> + =A0 =A0 =A0 default_backing_dev_info.ra_pages =3D vm_max_readahead_kb
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 * 1024 / PAGE_CACHE_SIZE;
> + =A0 =A0 =A0 return 0;
> +}
> +
> +early_param("readahead", readahead);
> +

-Ankit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
