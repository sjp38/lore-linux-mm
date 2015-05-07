Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 44D576B006E
	for <linux-mm@kvack.org>; Wed,  6 May 2015 21:13:31 -0400 (EDT)
Received: by pdea3 with SMTP id a3so25544426pde.3
        for <linux-mm@kvack.org>; Wed, 06 May 2015 18:13:31 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id nb3si568249pbc.151.2015.05.06.18.13.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 06 May 2015 18:13:30 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v4 2/3] memory-failure: change type of action_result's
 param 3 to enum
Date: Thu, 7 May 2015 00:08:35 +0000
Message-ID: <20150507000835.GA2954@hori1.linux.bs1.fc.nec.co.jp>
References: <1429519480-11687-1-git-send-email-xiexiuqi@huawei.com>
 <1429519480-11687-3-git-send-email-xiexiuqi@huawei.com>
In-Reply-To: <1429519480-11687-3-git-send-email-xiexiuqi@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <0CE1F142B620854BB8BB74912BD45A5B@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie XiuQi <xiexiuqi@huawei.com>
Cc: "rostedt@goodmis.org" <rostedt@goodmis.org>, "mingo@redhat.com" <mingo@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "koct9i@gmail.com" <koct9i@gmail.com>, "hpa@linux.intel.com" <hpa@linux.intel.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "luto@amacapital.net" <luto@amacapital.net>, "nasa4836@gmail.com" <nasa4836@gmail.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "bhelgaas@google.com" <bhelgaas@google.com>, "bp@suse.de" <bp@suse.de>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jingle.chen@huawei.com" <jingle.chen@huawei.com>

On Mon, Apr 20, 2015 at 04:44:39PM +0800, Xie XiuQi wrote:
> Change type of action_result's param 3 to enum for type consistency,
> and rename mf_outcome to mf_result for clearly.
>=20
> Signed-off-by: Xie XiuQi <xiexiuqi@huawei.com>

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  include/linux/mm.h  | 2 +-
>  mm/memory-failure.c | 3 ++-
>  2 files changed, 3 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 8413615..93c4a00 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2156,7 +2156,7 @@ extern int soft_offline_page(struct page *page, int=
 flags);
>  /*
>   * Error handlers for various types of pages.
>   */
> -enum mf_outcome {
> +enum mf_result {
>  	MF_IGNORED,	/* Error: cannot be handled */
>  	MF_FAILED,	/* Error: handling failed */
>  	MF_DELAYED,	/* Will be handled later */
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 6f5748d..f074f8e 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -847,7 +847,8 @@ static struct page_state {
>   * "Dirty/Clean" indication is not 100% accurate due to the possibility =
of
>   * setting PG_dirty outside page lock. See also comment above set_page_d=
irty().
>   */
> -static void action_result(unsigned long pfn, enum mf_action_page_type ty=
pe, int result)
> +static void action_result(unsigned long pfn, enum mf_action_page_type ty=
pe,
> +			  enum mf_result result)
>  {
>  	pr_err("MCE %#lx: recovery action for %s: %s\n",
>  		pfn, action_page_types[type], action_name[result]);
> --=20
> 1.8.3.1
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
