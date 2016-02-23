Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 806C06B026C
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 01:38:30 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id b205so185499033wmb.1
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 22:38:30 -0800 (PST)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id x186si37749827wme.12.2016.02.22.22.38.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Feb 2016 22:38:28 -0800 (PST)
Received: by mail-wm0-x22a.google.com with SMTP id g62so195242809wme.0
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 22:38:28 -0800 (PST)
Date: Tue, 23 Feb 2016 07:38:25 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC][PATCH 7/7] pkeys: add details of system call use to
 Documentation/
Message-ID: <20160223063824.GA21091@gmail.com>
References: <20160223011107.FB9B8215@viggo.jf.intel.com>
 <20160223011118.954E64B7@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160223011118.954E64B7@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com, linux-api@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org


* Dave Hansen <dave@sr71.net> wrote:

> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> This spells out all of the pkey-related system calls that we have
> and provides some example code fragments to demonstrate how we
> expect them to be used.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: linux-api@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: x86@kernel.org
> Cc: torvalds@linux-foundation.org
> Cc: akpm@linux-foundation.org
> ---
> 
>  b/Documentation/x86/protection-keys.txt |   63 ++++++++++++++++++++++++++++++++
>  1 file changed, 63 insertions(+)

Please also add pkeys testcases to tools/tests/self-tests.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
