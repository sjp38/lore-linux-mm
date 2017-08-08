Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4BFA36B037C
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 05:58:22 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id u19so13205545qtc.14
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 02:58:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 140si850588qki.153.2017.08.08.02.58.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 02:58:21 -0700 (PDT)
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
References: <20170806140425.20937-1-riel@redhat.com>
 <a0d79f77-f916-d3d6-1d61-a052581dbd4a@oracle.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <bfdab709-e5b2-0d26-1c0f-31535eda1678@redhat.com>
Date: Tue, 8 Aug 2017 11:58:13 +0200
MIME-Version: 1.0
In-Reply-To: <a0d79f77-f916-d3d6-1d61-a052581dbd4a@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, riel@redhat.com, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, colm@allcosts.net, akpm@linux-foundation.org, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com

On 08/07/2017 08:23 PM, Mike Kravetz wrote:
> If my thoughts above are correct, what about returning EINVAL if one
> attempts to set MADV_DONTFORK on mappings set up for sharing?

That's my preference as well.  If there is a use case for shared or
non-anonymous mappings, then we can implement MADV_DONTFORK with the
semantics for this use case.  If we pick some arbitrary semantics now,
without any use case, we might end up with something that's not actually
useful.

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
