Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1EF8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 06:12:40 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id u13-v6so10941677pfm.8
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 03:12:40 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id o33-v6si11673177plb.489.2018.09.10.03.12.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 03:12:38 -0700 (PDT)
Message-ID: <0663b867003511f1ca652cef6acce589a5184a4b.camel@linux.intel.com>
Subject: Re: [RFC 02/12] mm: Generalize the mprotect implementation to
 support extensions
From: Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>
Date: Mon, 10 Sep 2018 13:12:31 +0300
In-Reply-To: <2dcbb08ed8804e02538a73ee05a4283c54180e36.1536356108.git.alison.schofield@intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
	 <2dcbb08ed8804e02538a73ee05a4283c54180e36.1536356108.git.alison.schofield@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alison Schofield <alison.schofield@intel.com>, dhowells@redhat.com, tglx@linutronix.de
Cc: Kai Huang <kai.huang@intel.com>, Jun Nakajima <jun.nakajima@intel.com>, Kirill Shutemov <kirill.shutemov@intel.com>, Dave Hansen <dave.hansen@intel.com>, jmorris@namei.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org

On Fri, 2018-09-07 at 15:34 -0700, Alison Schofield wrote:
> Today mprotect is implemented to support legacy mprotect behavior
> plus an extension for memory protection keys. Make it more generic
> so that it can support additional extensions in the future.
> 
> This is done is preparation for adding a new system call for memory
> encyption keys. The intent is that the new encrypted mprotect will be
> another extension to legacy mprotect.
> 
> Signed-off-by: Alison Schofield <alison.schofield@intel.com>
> ---
>  mm/mprotect.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 68dc476310c0..56e64ef7931e 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -35,6 +35,8 @@
>  
>  #include "internal.h"
>  
> +#define NO_PKEY  -1

This commit does not make anything more generic but it does take
away a magic number. The code change is senseful. The commit
message is nonsense.

PS. Please use @linux.intel.com for LKML.

/Jarkko
