Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D336C6B0023
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 14:44:46 -0400 (EDT)
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 14 Sep 2011 14:41:57 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8EIfl6t261780
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 14:41:48 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8EIfMtO026783
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 12:41:22 -0600
Subject: Re: [RFC PATCH 2/2] mm: restrict access to /proc/slabinfo
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110910164134.GA2442@albatros>
References: <20110910164001.GA2342@albatros>
	 <20110910164134.GA2442@albatros>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 14 Sep 2011 11:41:41 -0700
Message-ID: <1316025701.4478.65.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: kernel-hardening@lists.openwall.com, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 2011-09-10 at 20:41 +0400, Vasiliy Kulikov wrote:
> @@ -4584,7 +4584,8 @@ static const struct file_operations proc_slabstats_operations = {
>  
>  static int __init slab_proc_init(void)
>  {
> -       proc_create("slabinfo",S_IWUSR|S_IRUGO,NULL,&proc_slabinfo_operations);
> +       proc_create("slabinfo", S_IWUSR | S_IRUSR, NULL,
> +                   &proc_slabinfo_operations);
>  #ifdef CONFIG_DEBUG_SLAB_LEAK
>         proc_create("slab_allocators", 0, NULL, &proc_sla 

If you respin this, please don't muck with the whitespace.  Otherwise,
I'm fine with this.  Distros are already starting to do this anyway in
userspace.

Reviewed-by: Dave Hansen <dave@linux.vnet.ibm.com>

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
