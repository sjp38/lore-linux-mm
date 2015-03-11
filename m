Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id DF30090002E
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 02:32:11 -0400 (EDT)
Received: by wghn12 with SMTP id n12so6854181wgh.6
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 23:32:11 -0700 (PDT)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com. [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id c8si4149930wjw.102.2015.03.10.23.32.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Mar 2015 23:32:10 -0700 (PDT)
Received: by wiwh11 with SMTP id h11so8823782wiw.5
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 23:32:10 -0700 (PDT)
Date: Wed, 11 Mar 2015 07:32:05 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 2/3] mtrr, x86: Fix MTRR lookup to handle inclusive entry
Message-ID: <20150311063205.GC29788@gmail.com>
References: <1426018997-12936-1-git-send-email-toshi.kani@hp.com>
 <1426018997-12936-3-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426018997-12936-3-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl


* Toshi Kani <toshi.kani@hp.com> wrote:

> When an MTRR entry is inclusive to a requested range, i.e.
> the start and end of the request are not within the MTRR
> entry range but the range contains the MTRR entry entirely,
> __mtrr_type_lookup() ignores such case because both
> start_state and end_state are set to zero.

'ignores such a case' or 'ignores such cases'.

> This patch fixes the issue by adding a new flag, inclusive,

s/inclusive/'inclusive'

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
