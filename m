Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id 84E936B0256
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 12:24:59 -0400 (EDT)
Received: by ykdg206 with SMTP id g206so12146671ykd.1
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 09:24:59 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id u62si4005559ywu.90.2015.09.29.09.24.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Sep 2015 09:24:58 -0700 (PDT)
Message-ID: <560ABB57.6080607@citrix.com>
Date: Tue, 29 Sep 2015 17:24:55 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] [PATCHv3 00/10] mm, xen/balloon: memory hotplug improvements
References: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
Cc: linux-mm@kvack.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Daniel Kiper <daniel.kiper@oracle.com>

On 30/07/15 18:03, David Vrabel wrote:
> The series improves the use of hotplug memory in the Xen balloon
> driver.
> 
> - Reliably find a non-conflicting location for the hotplugged memory
>   (this fixes memory hotplug in a number of cases, particularly in
>   dom0).
> 
> - Use hotplugged memory for alloc_xenballooned_pages() (keeping more
>   memory available for the domain and reducing fragmentation of the
>   p2m).

Applied to for-linus-4.4.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
