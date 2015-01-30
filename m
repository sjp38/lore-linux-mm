Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id D65946B0038
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:48:44 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id r20so3118772wiv.4
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 06:48:44 -0800 (PST)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id dc6si6998869wib.94.2015.01.30.06.48.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 06:48:43 -0800 (PST)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Fri, 30 Jan 2015 14:48:42 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 1D2C2219005C
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 14:48:36 +0000 (GMT)
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t0UEmcQ252887592
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 14:48:38 GMT
Received: from d06av12.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t0UEmbYG001938
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 07:48:38 -0700
Date: Fri, 30 Jan 2015 15:48:30 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 12/19] s390: expose number of page table levels
Message-ID: <20150130154830.6e5c4774@mschwide>
In-Reply-To: <1422629008-13689-13-git-send-email-kirill.shutemov@linux.intel.com>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1422629008-13689-13-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Fri, 30 Jan 2015 16:43:21 +0200
"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
> index 8d11babf9aa5..ddf9ebd4c254 100644
> --- a/arch/s390/Kconfig
> +++ b/arch/s390/Kconfig
> @@ -155,6 +155,11 @@ config S390
>  config SCHED_OMIT_FRAME_POINTER
>  	def_bool y
> 
> +config PGTABLE_LEVELS
> +	int
> +	default 4 if 64BI

                     ^^^^ 64BIT

> +	default 2
> +
>  source "init/Kconfig"


-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
