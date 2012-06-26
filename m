Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id ED31E6B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:45:09 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 26 Jun 2012 10:45:08 -0600
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 8F956C92F83
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:16:56 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5QGGvSj126748
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:16:57 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5QGGsil014906
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 13:16:54 -0300
Message-ID: <4FE9E028.7010006@linux.vnet.ibm.com>
Date: Tue, 26 Jun 2012 09:15:36 -0700
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] mm/sparse: more check on mem_section number
References: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com> <1340466776-4976-4-git-send-email-shangw@linux.vnet.ibm.com>
In-Reply-To: <1340466776-4976-4-git-send-email-shangw@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

On 06/23/2012 08:52 AM, Gavin Shan wrote:
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -160,6 +160,8 @@ int __section_nr(struct mem_section* ms)
>  		     break;
>  	}
> 
> +	VM_BUG_ON(root_nr == NR_SECTION_ROOTS);
> +
>  	return (root_nr * SECTIONS_PER_ROOT) + (ms - root);
>  }

If you're going to bother with a VM_BUG_ON(), I'd probably make it:

	VM_BUG_ON(root_nr >= NR_SECTION_ROOTS);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
