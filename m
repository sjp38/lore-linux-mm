Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 26E116B000A
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 19:29:26 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id l7-v6so5045261plg.6
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 16:29:26 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w90-v6si25887372pfk.208.2018.10.10.16.29.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 16:29:24 -0700 (PDT)
Date: Wed, 10 Oct 2018 16:29:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 1/3] mm: zero remaining unavailable struct pages
Message-Id: <20181010162922.ceea68916c51f08c54b18d4e@linux-foundation.org>
In-Reply-To: <20181002143821.5112-2-msys.mizuma@gmail.com>
References: <20181002143821.5112-1-msys.mizuma@gmail.com>
	<20181002143821.5112-2-msys.mizuma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masayoshi Mizuma <msys.mizuma@gmail.com>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Michal Hocko <mhocko@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org

On Tue,  2 Oct 2018 10:38:19 -0400 Masayoshi Mizuma <msys.mizuma@gmail.com> wrote:

> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> ...
>
> Fixes: f7f99100d8d9 ("mm: stop zeroing memory during allocation in vmemmap")
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Tested-by: Oscar Salvador <osalvador@suse.de>
> Tested-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>

This patch and [2/3] should have had your Signed-off-by:, since you
were on the patch delivery path.  As explained in
Documentation/process/submitting-patches.rst, section 11.

I have made that change to my copy of these two patches.
