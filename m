Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8AE7A6B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 10:56:18 -0500 (EST)
Received: by mail-qk0-f177.google.com with SMTP id s68so30082722qkh.3
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 07:56:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u144si7683280qka.104.2016.01.22.07.56.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 07:56:17 -0800 (PST)
From: Rik van Riel <riel@redhat.com>
Subject: [LSF/MM TOPIC] VM containers
Message-ID: <56A2511F.1080900@redhat.com>
Date: Fri, 22 Jan 2016 10:56:15 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linuxfoundation.org
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux kernel Mailing List <linux-kernel@vger.kernel.org>, KVM list <kvm@vger.kernel.org>

Hi,

I am trying to gauge interest in discussing VM containers at the LSF/MM
summit this year. Projects like ClearLinux, Qubes, and others are all
trying to use virtual machines as better isolated containers.

That changes some of the goals the memory management subsystem has,
from "use all the resources effectively" to "use as few resources as
necessary, in case the host needs the memory for something else".

These VMs could be as small as running just one application, so this
goes a little further than simply trying to squeeze more virtual
machines into a system with frontswap and cleancache.

Single-application VM sandboxes could also get their data differently,
using (partial) host filesystem passthrough, instead of a virtual
block device. This may change the relative utility of caching data
inside the guest page cache, versus freeing up that memory and
allowing the host to use it to cache things.

Are people interested in discussing this at LSF/MM, or is it better
saved for a different forum?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
