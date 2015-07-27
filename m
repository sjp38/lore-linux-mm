Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id E65846B0038
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 07:01:58 -0400 (EDT)
Received: by ykfw194 with SMTP id w194so65901283ykf.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 04:01:58 -0700 (PDT)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id g63si12325128ywd.182.2015.07.27.04.01.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Jul 2015 04:01:57 -0700 (PDT)
Message-ID: <55B60F6E.3040901@citrix.com>
Date: Mon, 27 Jul 2015 12:01:02 +0100
From: Julien Grall <julien.grall@citrix.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] [PATCHv2 10/10] xen/balloon: pre-allocate p2m entries
 for ballooned pages
References: <1437738468-24110-1-git-send-email-david.vrabel@citrix.com>
	<1437738468-24110-11-git-send-email-david.vrabel@citrix.com>
	<55B2C882.8050903@citrix.com> <55B5FA39.8000401@citrix.com>
In-Reply-To: <55B5FA39.8000401@citrix.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>, xen-devel@lists.xenproject.org
Cc: linux-mm@kvack.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-kernel@vger.kernel.org

On 27/07/15 10:30, David Vrabel wrote:
> On 25/07/15 00:21, Julien Grall wrote:
>> On 24/07/2015 12:47, David Vrabel wrote:
>>> @@ -550,6 +551,11 @@ int alloc_xenballooned_pages(int nr_pages, struct
>>> page **pages)
>>>           page = balloon_retrieve(true);
>>>           if (page) {
>>>               pages[pgno++] = page;
>>> +#ifdef CONFIG_XEN_HAVE_PVMMU
>>> +            ret = xen_alloc_p2m_entry(page_to_pfn(page));
>>
>> Don't you want to call this function only when the guest is not using
>> auto-translated physmap?
> 
> xen_alloc_p2m_entry() is a nop in auto-xlate guests, so no need for an
> additional check here.

I don't have the impression it's the case or it's not obvious.

For instance xen_p2m_addr, used within with the xen_alloc_p2m_entry (old
name alloc_p2m) is never set for auto-xlate guests. Therefore the value
is 0.

Same for p2m_identity and p2m_missing & co.

Regards,

-- 
Julien Grall

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
