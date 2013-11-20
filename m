Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id DA0816B0038
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 23:37:22 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fa1so487082pad.24
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 20:37:22 -0800 (PST)
Received: from psmtp.com ([74.125.245.143])
        by mx.google.com with SMTP id oy2si13233814pbc.69.2013.11.19.20.37.19
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 20:37:20 -0800 (PST)
Date: Wed, 20 Nov 2013 15:37:06 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH -V2 5/5] powerpc: mm: book3s: Enable _PAGE_NUMA for book3s
Message-ID: <20131120043706.GD5281@iris.ozlabs.ibm.com>
References: <1384766893-10189-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1384766893-10189-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1384766893-10189-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Mon, Nov 18, 2013 at 02:58:13PM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> We steal the _PAGE_COHERENCE bit and use that for indicating NUMA ptes.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Paul Mackerras <paulus@samba.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
