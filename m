Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id B17156B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 10:23:00 -0500 (EST)
Received: by mail-qk0-f178.google.com with SMTP id o6so12265274qkc.2
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 07:23:00 -0800 (PST)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id m11si12021369qhm.9.2016.01.28.07.22.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Jan 2016 07:22:59 -0800 (PST)
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 28 Jan 2016 08:22:59 -0700
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 8EAF73E4003B
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 08:22:56 -0700 (MST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22035.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0SFMtdh33161226
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 15:22:55 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0SFMtxl013585
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 10:22:55 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [LSF/MM TOPIC] VM containers
In-Reply-To: <56A2511F.1080900@redhat.com>
Date: Thu, 28 Jan 2016 20:48:35 +0530
Message-ID: <87wpqtwx4k.fsf@linux.vnet.ibm.com>
References: <56A2511F.1080900@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, lsf-pc@lists.linuxfoundation.org
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux kernel Mailing List <linux-kernel@vger.kernel.org>, KVM list <kvm@vger.kernel.org>

Rik van Riel <riel@redhat.com> writes:

> Hi,
>
> I am trying to gauge interest in discussing VM containers at the LSF/MM
> summit this year. Projects like ClearLinux, Qubes, and others are all
> trying to use virtual machines as better isolated containers.
>
> That changes some of the goals the memory management subsystem has,
> from "use all the resources effectively" to "use as few resources as
> necessary, in case the host needs the memory for something else".
>
> These VMs could be as small as running just one application, so this
> goes a little further than simply trying to squeeze more virtual
> machines into a system with frontswap and cleancache.
>
> Single-application VM sandboxes could also get their data differently,
> using (partial) host filesystem passthrough, instead of a virtual
> block device. This may change the relative utility of caching data
> inside the guest page cache, versus freeing up that memory and
> allowing the host to use it to cache things.
>
> Are people interested in discussing this at LSF/MM, or is it better
> saved for a different forum?
>

I am interested in the topic. We did look at doing something similar on
ppc64 and most of our focus was in reducing boot time by cutting out the
overhead of guest bios (SLOF) and block layer (by using 9pfs).  I would
like to understand the MM challenges you have identified.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
