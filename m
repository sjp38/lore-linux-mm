Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5A16F6B0009
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 21:05:02 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id b35so55498162qge.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 18:05:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m20si10955053qgd.74.2016.02.25.18.05.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 18:05:01 -0800 (PST)
Subject: Re: [RFC][PATCH v3 0/2] mm/page_poison.c: Allow for zero poisoning
References: <1456356923-5164-1-git-send-email-keescook@chromium.org>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <56CFB2C9.7070204@redhat.com>
Date: Thu, 25 Feb 2016 18:04:57 -0800
MIME-Version: 1.0
In-Reply-To: <1456356923-5164-1-git-send-email-keescook@chromium.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@fedoraproject.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mathias Krause <minipli@googlemail.com>, Dave Hansen <dave.hansen@intel.com>, Jianyu Zhan <nasa4836@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/24/2016 03:35 PM, Kees Cook wrote:
> This is my attempt to rebase this series:
>
> [PATCHv2, 2/2] mm/page_poisoning.c: Allow for zero poisoning
> [PATCHv2, 1/2] mm/page_poison.c: Enable PAGE_POISONING as a separate option
>
> to the poisoning series in linux-next. It replaces the following mmotm:
>
> mm-page_poisoningc-allow-for-zero-poisoning.patch
> mm-page_poisoningc-allow-for-zero-poisoning-checkpatch-fixes.patch
> mm-page_poisonc-enable-page_poisoning-as-a-separate-option.patch
> mm-page_poisonc-enable-page_poisoning-as-a-separate-option-fix.patch
>
> These patches work for me (linux-next does not) when using
> CONFIG_PAGE_POISONING_ZERO=y
>
> I've marked this RFC because I did the rebase -- bugs should be blamed
> on me. :)
>
> -Kees
>

The rebase looks fine to me. Were there any more comments on this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
