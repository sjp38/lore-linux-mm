Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 70C216B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 07:12:20 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id x23so35663896wrb.6
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 04:12:20 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t30si3221241wra.224.2017.06.29.04.12.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Jun 2017 04:12:19 -0700 (PDT)
Date: Thu, 29 Jun 2017 13:12:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: Drop useless local parameters of
 __register_one_node()
Message-ID: <20170629111217.GA5032@dhcp22.suse.cz>
References: <1498013846-20149-1-git-send-email-douly.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1498013846-20149-1-git-send-email-douly.fnst@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dou Liyang <douly.fnst@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, David Rientjes <rientjes@google.com>, isimatu.yasuaki@jp.fujitsu.com

On Wed 21-06-17 10:57:26, Dou Liyang wrote:
> ... initializes local parameters "p_node" & "parent" for
> register_node().
> 
> But, register_node() does not use them.
> 
> Remove the related code of "parent" node, cleanup __register_one_node()
> and register_node().
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: isimatu.yasuaki@jp.fujitsu.com
> Signed-off-by: Dou Liyang <douly.fnst@cn.fujitsu.com>
> Acked-by: David Rientjes <rientjes@google.com>

I am sorry, this slipped through cracks.
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> V1 --> V2:
> Rebase it on 
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git akpm
> 
>  drivers/base/node.c | 9 ++-------
>  1 file changed, 2 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 73d39bc..d8dc830 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -288,7 +288,7 @@ static void node_device_release(struct device *dev)
>   *
>   * Initialize and register the node device.
>   */
> -static int register_node(struct node *node, int num, struct node *parent)
> +static int register_node(struct node *node, int num)
>  {
>  	int error;
>  
> @@ -567,19 +567,14 @@ static void init_node_hugetlb_work(int nid) { }
>  
>  int __register_one_node(int nid)
>  {
> -	int p_node = parent_node(nid);
> -	struct node *parent = NULL;
>  	int error;
>  	int cpu;
>  
> -	if (p_node != nid)
> -		parent = node_devices[p_node];
> -
>  	node_devices[nid] = kzalloc(sizeof(struct node), GFP_KERNEL);
>  	if (!node_devices[nid])
>  		return -ENOMEM;
>  
> -	error = register_node(node_devices[nid], nid, parent);
> +	error = register_node(node_devices[nid], nid);
>  
>  	/* link cpu under this node */
>  	for_each_present_cpu(cpu) {
> -- 
> 2.5.5
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
