Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 88BBF6B0038
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 23:37:23 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id hz1so6164622pad.26
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 20:37:23 -0800 (PST)
Received: from psmtp.com ([74.125.245.113])
        by mx.google.com with SMTP id vs7si13235288pbc.175.2013.11.19.20.37.19
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 20:37:20 -0800 (PST)
Date: Wed, 20 Nov 2013 15:35:06 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH -V2 1/5] powerpc: Use HPTE constants when updating hpte
 bits
Message-ID: <20131120043506.GA5281@iris.ozlabs.ibm.com>
References: <1384766893-10189-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1384766893-10189-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1384766893-10189-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Mon, Nov 18, 2013 at 02:58:09PM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> Even though we have same value for linux PTE bits and hash PTE pits

bits, not pits :)

> use the hash pte bits wen updating hash pte

when, not wen

> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

If you fix the spelling errors in the patch description:

Acked-by: Paul Mackerras <paulus@samba.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
