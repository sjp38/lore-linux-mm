Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7TIjoFg011559
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 14:45:50 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7TIjnKC453898
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 12:45:49 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7TIjnam031313
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 12:45:49 -0600
Subject: Re: [-mm PATCH]  Memory controller improve user interface
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20070829111030.9987.8104.sendpatchset@balbir-laptop>
References: <20070829111030.9987.8104.sendpatchset@balbir-laptop>
Content-Type: text/plain
Date: Wed, 29 Aug 2007 11:45:48 -0700
Message-Id: <1188413148.28903.113.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-08-29 at 16:40 +0530, Balbir Singh wrote:
> 
> 
> @@ -352,7 +353,7 @@ int mem_container_charge(struct page *pa
>                 kfree(pc);
>                 pc = race_pc;
>                 atomic_inc(&pc->ref_cnt);
> -               res_counter_uncharge(&mem->res, 1);
> +               res_counter_uncharge(&mem->res, MEM_CONTAINER_CHARGE_KB);
>                 css_put(&mem->css);
>                 goto done;
>         } 

Do these changes really need to happen anywhere besides the
user<->kernel boundary?  Why can't internal tracking be in pages?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
