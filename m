Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 539696B009C
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 18:06:55 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2405855dak.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 15:06:54 -0700 (PDT)
Date: Wed, 27 Jun 2012 15:06:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 3/3] mm/sparse: more check on mem_section number
In-Reply-To: <1340814968-2948-3-git-send-email-shangw@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.00.1206271506260.22985@chino.kir.corp.google.com>
References: <1340814968-2948-1-git-send-email-shangw@linux.vnet.ibm.com> <1340814968-2948-3-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mhocko@suse.cz, dave@linux.vnet.ibm.com, hannes@cmpxchg.org, akpm@linux-foundation.org

On Thu, 28 Jun 2012, Gavin Shan wrote:

> diff --git a/mm/sparse.c b/mm/sparse.c
> index a803599..8b8250e 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -149,6 +149,8 @@ int __section_nr(struct mem_section* ms)
>  		     break;
>  	}
>  
> +	VM_BUG_ON(root_nr >= NR_SECTION_ROOTS);
> +

VM_BUG_ON(root_nr == NR_SECTION_ROOTS);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
