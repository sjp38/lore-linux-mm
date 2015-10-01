Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 539EC6B028E
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 07:51:07 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so24532906wic.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 04:51:06 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id zb2si6865203wjc.95.2015.10.01.04.51.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 01 Oct 2015 04:51:06 -0700 (PDT)
Date: Thu, 1 Oct 2015 13:50:24 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 05/25] x86, pkey: add PKRU xsave fields and data
 structure(s)
In-Reply-To: <20150928191819.925D0BD3@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1510011303420.4500@nanos>
References: <20150928191817.035A64E2@viggo.jf.intel.com> <20150928191819.925D0BD3@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com

On Mon, 28 Sep 2015, Dave Hansen wrote:
> +/*
> + * State component 9: 32-bit PKRU register.
> + */
> +struct pkru {
> +	u32 pkru;
> +} __packed;
> +
> +struct pkru_state {
> +	union {
> +		struct pkru		pkru;
> +		u8			pad_to_8_bytes[8];
> +	};

Why do you need two structs?

    struct pkru_state {
    	   u32 pkru;
	   u32 pad;
    }

should be sufficient. So instead of

       xsave.pkru_state.pkru.pkru

you get the more obvious

       xsave.pkru_state.pkru

Hmm?

Thanks,

	tglx



      

       

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
