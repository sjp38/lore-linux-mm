Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id F3BFA6B025F
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 08:43:00 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o124so29632644qke.9
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 05:43:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t64si3062129qkf.102.2017.08.09.05.42.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 05:42:59 -0700 (PDT)
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
References: <20170806140425.20937-1-riel@redhat.com>
 <20170807132257.GH32434@dhcp22.suse.cz>
 <20170807134648.GI32434@dhcp22.suse.cz> <1502117991.6577.13.camel@redhat.com>
 <20170809095957.kv47or2w4obaipkn@node.shutemov.name>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <8fe8040c-7595-ec09-6ce7-0da4fadc82c4@redhat.com>
Date: Wed, 9 Aug 2017 14:42:51 +0200
MIME-Version: 1.0
In-Reply-To: <20170809095957.kv47or2w4obaipkn@node.shutemov.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Rik van Riel <riel@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, mike.kravetz@oracle.com, linux-mm@kvack.org, colm@allcosts.net, akpm@linux-foundation.org, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, dave.hansen@intel.com, linux-api@vger.kernel.org

On 08/09/2017 11:59 AM, Kirill A. Shutemov wrote:
> It's not obvious to me what would break if kernel would ignore
> MADV_DONTFORK or MADV_DONTDUMP.

Ignoring MADV_DONTDUMP could cause secrets to be written to disk,
contrary to the expected security policy of the system.

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
