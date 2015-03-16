Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3D96B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 03:51:46 -0400 (EDT)
Received: by wibg7 with SMTP id g7so30498358wib.1
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 00:51:46 -0700 (PDT)
Received: from mail-we0-x235.google.com (mail-we0-x235.google.com. [2a00:1450:400c:c03::235])
        by mx.google.com with ESMTPS id fp8si16273581wic.70.2015.03.16.00.51.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 00:51:45 -0700 (PDT)
Received: by weop45 with SMTP id p45so6515933weo.0
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 00:51:44 -0700 (PDT)
Date: Mon, 16 Mar 2015 08:51:39 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 3/5] mtrr, x86: Fix MTRR state checks in
 mtrr_type_lookup()
Message-ID: <20150316075139.GB15955@gmail.com>
References: <1426282421-25385-1-git-send-email-toshi.kani@hp.com>
 <1426282421-25385-4-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426282421-25385-4-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl


* Toshi Kani <toshi.kani@hp.com> wrote:

> 'mtrr_state.enabled' contains FE (fixed MTRRs enabled) and
> E (MTRRs enabled) flags in MSR_MTRRdefType.  Intel SDM,
> section 11.11.2.1, defines these flags as follows:
>  - All MTRRs are disabled when the E flag is clear.
>    The FE flag has no affect when the E flag is clear.
>  - The default type is enabled when the E flag is set.
>  - MTRR variable ranges are enabled when the E flag is set.
>  - MTRR fixed ranges are enabled when both E and FE flags
>    are set.
> 
> MTRR state checks in __mtrr_type_lookup() do not follow the
> SDM definitions.  Therefore, this patch fixes the MTRR state
> checks according to the SDM.  This patch defines the flags
> in mtrr_state.enabled as follows.  print_mtrr_state() is also
> updated.
>  - FE flag: MTRR_STATE_MTRR_FIXED_ENABLED
>  - E  flag: MTRR_STATE_MTRR_ENABLED
> 
> Lastly, this patch fixes the 'else if (start < 0x1000000)',
> which checks a fixed range but has an extra-zero in the
> address, to 'else' with no condition.

Firstly, this does multiple bug fixes in a single patch, which is a 
no-no: please split it up into separate patches.

Secondly, please also outline the differences between the old code and 
the new code - don't just list the SDM logic and state that we are 
updating to it.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
