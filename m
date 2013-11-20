Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id D47836B0031
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 23:37:21 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id y13so2935560pdi.33
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 20:37:21 -0800 (PST)
Received: from psmtp.com ([74.125.245.168])
        by mx.google.com with SMTP id cl4si9622084pad.256.2013.11.19.20.37.19
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 20:37:20 -0800 (PST)
Date: Wed, 20 Nov 2013 15:35:55 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH -V2 2/5] powerpc: Free up _PAGE_COHERENCE for numa fault
 use later
Message-ID: <20131120043555.GB5281@iris.ozlabs.ibm.com>
References: <1384766893-10189-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1384766893-10189-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1384766893-10189-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Mon, Nov 18, 2013 at 02:58:10PM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> Set  memory coherence always on hash64 config. If
> a platform cannot have memory coherence always set they
> can infer that from _PAGE_NO_CACHE and _PAGE_WRITETHRU
> like in lpar. So we dont' really need a separate bit
> for tracking _PAGE_COHERENCE.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Paul Mackerras <paulus@samba.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
