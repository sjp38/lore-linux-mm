Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id CCA6682F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 10:47:43 -0400 (EDT)
Received: by wmll128 with SMTP id l128so14080149wml.0
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 07:47:43 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id eq8si9408695wjc.105.2015.10.30.07.47.42
        for <linux-mm@kvack.org>;
        Fri, 30 Oct 2015 07:47:42 -0700 (PDT)
Date: Fri, 30 Oct 2015 15:47:30 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v2 UPDATE-2 3/3] ACPI/APEI/EINJ: Allow memory error
 injection to NVDIMM
Message-ID: <20151030144730.GG20952@pd.tnic>
References: <1445894544-21382-1-git-send-email-toshi.kani@hpe.com>
 <20151030094029.GC20952@pd.tnic>
 <1446212931.20657.161.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1446212931.20657.161.camel@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>, rjw@rjwysocki.net
Cc: tony.luck@intel.com, akpm@linux-foundation.org, dan.j.williams@intel.com, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Oct 30, 2015 at 07:48:51AM -0600, Toshi Kani wrote:
> Yes, the brackets are not necessary. I put them as self-explanatory of
> the precedence. Shall I remove them, and send you an updated patch?

Not necessary, I have my high hopes that Rafael can remove them when
applying :-)

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
