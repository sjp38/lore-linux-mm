Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 99CC96B0038
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 13:20:56 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 144so176630581pfv.5
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 10:20:56 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id 33si48907606ply.89.2016.12.13.10.20.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Dec 2016 10:20:55 -0800 (PST)
Message-ID: <1481653252.2473.51.camel@HansenPartnership.com>
Subject: Re: [LSF/MM TOPIC] Un-addressable device memory and block/fs
 implications
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Tue, 13 Dec 2016 10:20:52 -0800
In-Reply-To: <20161213181511.GB2305@redhat.com>
References: <20161213181511.GB2305@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Tue, 2016-12-13 at 13:15 -0500, Jerome Glisse wrote:
> I would like to discuss un-addressable device memory in the context 
> of filesystem and block device. Specificaly how to handle write-back,
> read, ... when a filesystem page is migrated to device memory that 
> CPU can not access.
> 
> I intend to post a patchset leveraging the same idea as the existing
> block bounce helper (block/bounce.c) to handle this. I believe this 
> is worth discussing during summit see how people feels about such 
> plan and if they have better ideas.

Isn't this pretty much what the transcendent memory interfaces we
currently have are for?  It's current use cases seem to be compressed
swap and distributed memory, but there doesn't seem to be any reason in
principle why you can't use the interface as well.

James


> I also like to join discussions on:
>   - Peer-to-Peer DMAs between PCIe devices
>   - CDM coherent device memory
>   - PMEM
>   - overall mm discussions
> 
> Cheers,
> JA(C)rA'me
> --
> To unsubscribe from this list: send the line "unsubscribe linux
> -fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
