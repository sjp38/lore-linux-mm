Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE9D6B0032
	for <linux-mm@kvack.org>; Tue,  5 May 2015 10:19:18 -0400 (EDT)
Received: by wgso17 with SMTP id o17so184998133wgs.1
        for <linux-mm@kvack.org>; Tue, 05 May 2015 07:19:18 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id ay8si17127885wib.96.2015.05.05.07.19.08
        for <linux-mm@kvack.org>;
        Tue, 05 May 2015 07:19:08 -0700 (PDT)
Date: Tue, 5 May 2015 16:19:06 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v4 1/7] mm, x86: Document return values of mapping funcs
Message-ID: <20150505141906.GI3910@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
 <1427234921-19737-2-git-send-email-toshi.kani@hp.com>
 <20150505111913.GH3910@pd.tnic>
 <1430833596.23761.245.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1430833596.23761.245.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Tue, May 05, 2015 at 07:46:36AM -0600, Toshi Kani wrote:
> Agreed.  This patch-set was originally a small set of patches, but was
> extended later with additional patches, which ended up with touching the
> same place again.  I will reorganize the patch-set.

Ok, but please wait until I take a look at the rest.

Thanks.

Btw, is there anything else MTRR-related pending for tip?

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
