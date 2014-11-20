Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 26B986B0038
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 19:50:43 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id hn15so1987981igb.3
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 16:50:43 -0800 (PST)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com. [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id k15si645673iok.8.2014.11.19.16.50.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Nov 2014 16:50:42 -0800 (PST)
Received: by mail-ie0-f179.google.com with SMTP id rp18so1726042iec.24
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 16:50:41 -0800 (PST)
Date: Wed, 19 Nov 2014 16:50:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/numa balancing: Rearrange Kconfig entry
In-Reply-To: <1413425935-24767-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1411191650180.9079@chino.kir.corp.google.com>
References: <1413425935-24767-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 16 Oct 2014, Aneesh Kumar K.V wrote:

> Add the default enable config option after the NUMA_BALANCING option
> so that it appears related in the nconfig interface.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

Hasn't hit Linus's tree yet, so there's still time to ack!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
