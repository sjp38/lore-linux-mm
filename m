Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id A8F426B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 03:50:00 -0400 (EDT)
Received: by weop45 with SMTP id p45so6489791weo.0
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 00:50:00 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id cn12si16287890wjb.46.2015.03.16.00.49.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 00:49:59 -0700 (PDT)
Received: by wixw10 with SMTP id w10so25464729wix.0
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 00:49:58 -0700 (PDT)
Date: Mon, 16 Mar 2015 08:49:54 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 2/5] mtrr, x86: Fix MTRR lookup to handle inclusive
 entry
Message-ID: <20150316074954.GA15955@gmail.com>
References: <1426282421-25385-1-git-send-email-toshi.kani@hp.com>
 <1426282421-25385-3-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426282421-25385-3-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl


* Toshi Kani <toshi.kani@hp.com> wrote:

> When an MTRR entry is inclusive to a requested range, i.e.
> the start and end of the request are not within the MTRR
> entry range but the range contains the MTRR entry entirely,
> __mtrr_type_lookup() ignores such a case because both
> start_state and end_state are set to zero.
> 
> This patch fixes the issue by adding a new flag, 'inclusive',
> to detect the case.  This case is then handled in the same
> way as (!start_state && end_state).

It would be nice to discuss the high level effects of this fix in the 
changelog: i.e. what (presumably bad thing) happened before the 
change, what will happen after the change? What did users experience 
before the patch, and what will users experience after the patch?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
