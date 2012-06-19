Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id DBEB96B0062
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 10:31:26 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 19 Jun 2012 08:31:25 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id EA3D1C40001
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 14:31:19 +0000 (WET)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5JEV2mE120092
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 08:31:04 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5JEUsWo018975
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 08:30:54 -0600
Message-ID: <4FE08D1A.5060400@linux.vnet.ibm.com>
Date: Tue, 19 Jun 2012 09:30:50 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/10] zcache: fix a compile warning
References: <4FE0392E.3090300@linux.vnet.ibm.com> <4FE03961.5050001@linux.vnet.ibm.com>
In-Reply-To: <4FE03961.5050001@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 06/19/2012 03:33 AM, Xiao Guangrong wrote:

> fix:
> 
> drivers/staging/zcache/zcache-main.c: In function a??zcache_comp_opa??:
> drivers/staging/zcache/zcache-main.c:112:2: warning: a??reta?? may be used uninitial
> 
> Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
> ---
>  drivers/staging/zcache/zcache-main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
> index 32fe0ba..74a3ac8 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -93,7 +93,7 @@ static inline int zcache_comp_op(enum comp_op op,
>  				u8 *dst, unsigned int *dlen)
>  {
>  	struct crypto_comp *tfm;
> -	int ret;
> +	int ret = -1;
> 
>  	BUG_ON(!zcache_comp_pcpu_tfms);
>  	tfm = *per_cpu_ptr(zcache_comp_pcpu_tfms, get_cpu());


What about adding a default case in the switch like this?

default:
	ret = -EINVAL;

That way we don't assign ret twice.

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
