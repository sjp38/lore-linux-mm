Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id A41036B0254
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 18:18:08 -0400 (EDT)
Received: by qgez77 with SMTP id z77so188381574qge.1
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 15:18:08 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r12si30790999qha.65.2015.10.06.15.18.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Oct 2015 15:18:08 -0700 (PDT)
Received: from akpm3.mtv.corp.google.com (unknown [216.239.45.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 50BB4117B
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 22:18:07 +0000 (UTC)
Date: Tue, 6 Oct 2015 15:18:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/1] mm/vmstat.c: uninline node_page_state()
Message-Id: <20151006151806.a684eff1a212cbee5484cc20@linux-foundation.org>
In-Reply-To: <56144788.RD/yrs/8D4zm1CBk%akpm@linux-foundation.org>
References: <56144788.RD/yrs/8D4zm1CBk%akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On Tue, 06 Oct 2015 15:13:28 -0700 akpm@linux-foundation.org wrote:

> + * Determine the per node value of a stat item. This function
> + * is called frequently in a NUMA machine, so try to be as
> + * frugal as possible.

The comment lies, doesn't it?  node_page_state() is only used for
userspace meminfo display purposes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
