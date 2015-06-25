Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id E82CF6B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 13:11:12 -0400 (EDT)
Received: by yhjh26 with SMTP id h26so9978715yhj.3
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 10:11:12 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id r4si11761763yhg.164.2015.06.25.10.11.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Jun 2015 10:11:11 -0700 (PDT)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1 0/8] mm,xen/balloon: memory hotplug improvements
Date: Thu, 25 Jun 2015 18:10:55 +0100
Message-ID: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
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

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
