Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8EF379003C7
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 07:48:04 -0400 (EDT)
Received: by ykfw194 with SMTP id w194so17473189ykf.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 04:48:04 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id y139si5871632yke.97.2015.07.24.04.48.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Jul 2015 04:48:04 -0700 (PDT)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv2 00/10] mm, xen/balloon: memory hotplug improvements
Date: Fri, 24 Jul 2015 12:47:38 +0100
Message-ID: <1437738468-24110-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen-devel@lists.xenproject.org
Cc: David Vrabel <david.vrabel@citrix.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Kiper <daniel.kiper@oracle.com>

The series improves the use of hotplug memory in the Xen balloon
driver.

- Reliably find a non-conflicting location for the hotplugged memory
  (this fixes memory hotplug in a number of cases, particularly in
  dom0).

- Use hotplugged memory for alloc_xenballooned_pages() (keeping more
  memory available for the domain and reducing fragmentation of the
  p2m).

Changes in v2:
- New BP_WAIT state to signal the balloon process to wait for
  userspace to online the new memory.
- Preallocate P2M entries in alloc_xenballooned_pages() so they do not
  need allocated later (in a context where GFP_KERNEL allocations are
  not possible).

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
