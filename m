Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 77BA66B0254
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 05:31:11 -0400 (EDT)
Received: by ykfw194 with SMTP id w194so64499982ykf.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 02:31:11 -0700 (PDT)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id f65si12227004ywa.16.2015.07.27.02.31.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Jul 2015 02:31:10 -0700 (PDT)
Message-ID: <55B5FA39.8000401@citrix.com>
Date: Mon, 27 Jul 2015 10:30:33 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] [PATCHv2 10/10] xen/balloon: pre-allocate p2m entries
 for ballooned pages
References: <1437738468-24110-1-git-send-email-david.vrabel@citrix.com>
	<1437738468-24110-11-git-send-email-david.vrabel@citrix.com>
 <55B2C882.8050903@citrix.com>
In-Reply-To: <55B2C882.8050903@citrix.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julien Grall <julien.grall@citrix.com>, David Vrabel <david.vrabel@citrix.com>, xen-devel@lists.xenproject.org
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-mm@kvack.org, Daniel Kiper <daniel.kiper@oracle.com>, linux-kernel@vger.kernel.org

On 25/07/15 00:21, Julien Grall wrote:
> On 24/07/2015 12:47, David Vrabel wrote:
>> @@ -550,6 +551,11 @@ int alloc_xenballooned_pages(int nr_pages, struct
>> page **pages)
>>           page = balloon_retrieve(true);
>>           if (page) {
>>               pages[pgno++] = page;
>> +#ifdef CONFIG_XEN_HAVE_PVMMU
>> +            ret = xen_alloc_p2m_entry(page_to_pfn(page));
> 
> Don't you want to call this function only when the guest is not using
> auto-translated physmap?

xen_alloc_p2m_entry() is a nop in auto-xlate guests, so no need for an
additional check here.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
