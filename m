Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id AA0786B0038
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 06:18:48 -0400 (EDT)
Received: by ykax123 with SMTP id x123so65316083yka.1
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 03:18:48 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id v203si12278678ywe.107.2015.07.27.03.18.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Jul 2015 03:18:47 -0700 (PDT)
Message-ID: <55B60583.3010903@citrix.com>
Date: Mon, 27 Jul 2015 11:18:43 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] [PATCHv2 08/10] xen/balloon: use hotplugged pages
 for foreign mappings etc.
References: <1437738468-24110-1-git-send-email-david.vrabel@citrix.com>
	<1437738468-24110-9-git-send-email-david.vrabel@citrix.com>
 <20150724185545.GD12824@l.oracle.com>
In-Reply-To: <20150724185545.GD12824@l.oracle.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, David Vrabel <david.vrabel@citrix.com>
Cc: xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 24/07/15 19:55, Konrad Rzeszutek Wilk wrote:
> On Fri, Jul 24, 2015 at 12:47:46PM +0100, David Vrabel wrote:
>> alloc_xenballooned_pages() is used to get ballooned pages to back
>> foreign mappings etc.  Instead of having to balloon out real pages,
>> use (if supported) hotplugged memory.
>>
>> This makes more memory available to the guest and reduces
>> fragmentation in the p2m.
>>
>> If userspace is lacking a udev rule (or similar) to online hotplugged
> 
> Is that udev rule already in distros?

Not all, which makes me think that this behaviour should be enabled by
userspace (via a module parameter).  This would also allow me to drop
the timeout and fallback path which I put in to handle the no udev rule
case.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
