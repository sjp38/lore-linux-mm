Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1R8Q0kh025270
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 13:56:00 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1R8Q07i999484
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 13:56:00 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1R8Q0lO027474
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 08:26:00 GMT
Message-ID: <47C51D4B.6080501@linux.vnet.ibm.com>
Date: Wed, 27 Feb 2008 13:50:27 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: Add Pavel as the co-maintainer for memory resource controller
References: <20080227040246.GA27018@balbir.in.ibm.com> <47C51331.8060700@openvz.org>
In-Reply-To: <47C51331.8060700@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Pavel Emelyanov wrote:
> I'm also interested in supporting this feature, all the more
> so, we're planning to move OpenVZ development branch to 2.6.25
> soon to make use of namespaces and controller(s) that are
> already there.
> 
> Please, add me as the co-maintainer of a memory controller.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ---
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 4623c24..85bfcd4 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -2642,6 +2642,8 @@ S:	Maintained
>  MEMORY RESOURCE CONTROLLER
>  P:	Balbir Singh
>  M:	balbir@linux.vnet.ibm.com
> +P:	Pavel Emelyanov
> +M:	xemul@openvz.org
>  L:	linux-mm@kvack.org
>  L:	linux-kernel@vger.kernel.org
>  S:	Maintained
> 

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

KAMEZAWA and others are you interested in adding your names as well?

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
