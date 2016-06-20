Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 581B96B0005
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 19:11:28 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id hx8so767109obb.0
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 16:11:28 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h18si35942821pfk.107.2016.06.20.16.11.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 16:11:27 -0700 (PDT)
Date: Mon, 20 Jun 2016 16:11:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] mm/page_ref: introduce page_ref_inc_return
Message-Id: <20160620161126.082c51572524a39f599ecc52@linux-foundation.org>
In-Reply-To: <1466419093-114348-2-git-send-email-borntraeger@de.ibm.com>
References: <1466419093-114348-1-git-send-email-borntraeger@de.ibm.com>
	<1466419093-114348-2-git-send-email-borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, Radim =?UTF-8?Q?Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, KVM <kvm@vger.kernel.org>, Cornelia Huck <cornelia.huck@de.ibm.com>, linux-s390 <linux-s390@vger.kernel.org>, David Hildenbrand <dahi@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 20 Jun 2016 12:38:13 +0200 Christian Borntraeger <borntraeger@de.ibm.com> wrote:

> From: David Hildenbrand <dahi@linux.vnet.ibm.com>
> 
> Let's introduce that helper.
> 
> ...
>
> +static inline int page_ref_inc_return(struct page *page)
> +{
> +	int ret = atomic_inc_return(&page->_refcount);
> +
> +	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_and_return))
> +		__page_ref_mod_and_return(page, 1, ret);
> +	return ret;
> +}

Acked-by: Andrew Morton <akpm@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
