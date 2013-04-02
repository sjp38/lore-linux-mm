Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id A2D156B0039
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 11:19:01 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id k13so3253868wgh.3
        for <linux-mm@kvack.org>; Tue, 02 Apr 2013 08:19:00 -0700 (PDT)
MIME-Version: 1.0
Reply-To: konrad@darnok.org
In-Reply-To: <1364870780-16296-8-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1364870780-16296-1-git-send-email-liwanp@linux.vnet.ibm.com> <1364870780-16296-8-git-send-email-liwanp@linux.vnet.ibm.com>
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Date: Tue, 2 Apr 2013 11:18:39 -0400
Message-ID: <CAPbh3rvheDqL6U4P6L++We-Ra=Cw_fNrdPGfhV3tzVA_eW5CxQ@mail.gmail.com>
Subject: Re: [PATCH v5 7/8] staging: zcache: introduce zero-filled page stat count
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Fengguang Wu <fengguang.wu@intel.com>

> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -176,6 +176,8 @@ ssize_t zcache_pers_ate_eph;
>  ssize_t zcache_pers_ate_eph_failed;
>  ssize_t zcache_evicted_eph_zpages;
>  ssize_t zcache_evicted_eph_pageframes;
> +ssize_t zcache_zero_filled_pages;
> +ssize_t zcache_zero_filled_pages_max;

Is it possible to shove these in the debug.c file? And in debug.h just
have an extern?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
