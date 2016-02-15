Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5B2346B0009
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 00:26:41 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id wb13so198413988obb.1
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 21:26:41 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id m23si15050556oik.62.2016.02.14.21.26.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Feb 2016 21:26:40 -0800 (PST)
Date: Mon, 15 Feb 2016 16:24:49 +1100
From: Paul Mackerras <paulus@ozlabs.org>
Subject: Re: [PATCH V2 12/29] powerpc/mm: Move hash64 specific defintions to
 seperate header
Message-ID: <20160215052449.GE3797@oak.ozlabs.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1454923241-6681-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454923241-6681-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Mon, Feb 08, 2016 at 02:50:24PM +0530, Aneesh Kumar K.V wrote:
> Also split pgalloc 64k and 4k headers
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

In the subject: s/defintions/definitions/; s/seperate/separate/

A more detailed patch description would be good.  Apart from that,

Reviewed-by: Paul Mackerras <paulus@samba.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
