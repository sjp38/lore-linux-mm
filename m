Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A18206B01AD
	for <linux-mm@kvack.org>; Tue, 25 May 2010 20:53:04 -0400 (EDT)
From: "Shi, Alex" <alex.shi@intel.com>
Date: Wed, 26 May 2010 08:52:16 +0800
Subject: RE: [PATCH] slub: move kmem_cache_node into it's own cacheline
Message-ID: <6E3BC7F7C9A4BF4286DD4C043110F30B0B59958166@shsmsx502.ccr.corp.intel.com>
References: <20100520234714.6633.75614.stgit@gitlad.jf.intel.com>
 <AANLkTilfJh65QAkb9FPaqI3UEtbgwLuuoqSdaTtIsXWZ@mail.gmail.com>
 <6E3BC7F7C9A4BF4286DD4C043110F30B0B5969081B@shsmsx502.ccr.corp.intel.com>
 <4BFAC1FC.2030502@cs.helsinki.fi>
In-Reply-To: <4BFAC1FC.2030502@cs.helsinki.fi>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>, "cl@linux.com" <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

Tim reminder me that I need clearly add the following line to confirm my ag=
reement for this patch. Sorry for miss this.=20

Tested-by: Alex Shi <alex.shi@intel.com>=20

>-----Original Message-----
>From: Pekka Enberg [mailto:penberg@cs.helsinki.fi]
>Sent: Tuesday, May 25, 2010 2:14 AM
>To: Shi, Alex
>Cc: Duyck, Alexander H; cl@linux.com; linux-mm@kvack.org; Zhang Yanmin; Ch=
en, Tim C
>Subject: Re: [PATCH] slub: move kmem_cache_node into it's own cacheline
>
>Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
