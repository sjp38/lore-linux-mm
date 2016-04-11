Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 15AF66B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 10:23:45 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id td3so122504506pab.2
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 07:23:45 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id dj8si3918850pad.244.2016.04.11.07.23.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 07:23:44 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: [PATCH 06/19] arc: get rid of superfluous __GFP_REPEAT
Date: Mon, 11 Apr 2016 14:23:42 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075F4E9D497@us01wembx1.internal.synopsys.com>
References: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
 <1460372892-8157-7-git-send-email-mhocko@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

On Monday 11 April 2016 04:38 PM, Michal Hocko wrote:=0A=
> From: Michal Hocko <mhocko@suse.com>=0A=
>=0A=
> __GFP_REPEAT has a rather weak semantic but since it has been introduced=
=0A=
> around 2.6.12 it has been ignored for low order allocations.=0A=
>=0A=
> pte_alloc_one_kernel uses __get_order_pte but this is obviously=0A=
> always zero because BITS_FOR_PTE is not larger than 9 yet the page=0A=
> size is always larger than 4K.  This means that this flag has never=0A=
> been actually useful here because it has always been used only for=0A=
> PAGE_ALLOC_COSTLY requests.=0A=
>=0A=
> Cc: Vineet Gupta <vgupta@synopsys.com>=0A=
> Cc: linux-arch@vger.kernel.org=0A=
> Signed-off-by: Michal Hocko <mhocko@suse.com>=0A=
=0A=
Acked-by: Vineet Gupta <vgupta@synopsys.com>=0A=
=0A=
Thx,=0A=
-Vineet=0A=
=0A=
=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
