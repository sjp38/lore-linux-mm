Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BBB166B0033
	for <linux-mm@kvack.org>; Sat,  9 Dec 2017 19:21:57 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id p17so11427215pfh.18
        for <linux-mm@kvack.org>; Sat, 09 Dec 2017 16:21:57 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id z23si7294732pll.336.2017.12.09.16.21.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Dec 2017 16:21:56 -0800 (PST)
Subject: Re: pkeys: Support setting access rights for signal handlers
References: <5fee976a-42d4-d469-7058-b78ad8897219@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <c034f693-95d1-65b8-2031-b969c2771fed@intel.com>
Date: Sat, 9 Dec 2017 16:17:36 -0800
MIME-Version: 1.0
In-Reply-To: <5fee976a-42d4-d469-7058-b78ad8897219@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>, linux-mm <linux-mm@kvack.org>, x86@kernel.org, linux-arch <linux-arch@vger.kernel.org>, linux-x86_64@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

On 12/09/2017 01:16 PM, Florian Weimer wrote:
> The attached patch addresses a problem with the current x86 pkey
> implementation, which makes default-readable pkeys unusable from signal
> handlers because the default init_pkru value blocks access.

Thanks for looking into this!

What do you mean by "default-readable pkeys"?

I think you mean that, for any data that needs to be accessed to enter a
signal handler, it must be set to pkey=0 with the current
implementation.  All other keys are inaccessible when entering a signal
handler because the "init" value disables access.

My only nit with this is whether it is the *right* interface.  The
signal vs. XSAVE state thing is pretty x86 specific and I doubt that
this will be the last feature that we encounter that needs special
signal behavior.

A question more for the x86 maintainers is whether they would rather see
a pkeys-specific interface for this, or an XSAVE-specific interface
where you could specify a non-init XSAVE state for a set of XSAVE
components.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
