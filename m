Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 527536B0279
	for <linux-mm@kvack.org>; Mon, 29 May 2017 15:26:36 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id d14so25199501qkb.0
        for <linux-mm@kvack.org>; Mon, 29 May 2017 12:26:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z9si10273366qtb.168.2017.05.29.12.26.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 May 2017 12:26:35 -0700 (PDT)
Message-ID: <1496085991.29205.70.camel@redhat.com>
Subject: Re: [PATCH v4 1/8] x86/mm: Pass flush_tlb_info to
 flush_tlb_others() etc
From: Rik van Riel <riel@redhat.com>
Date: Mon, 29 May 2017 15:26:31 -0400
In-Reply-To: <c987470279e055d1f1e9d9664f922dbe86b9173d.1495990440.git.luto@kernel.org>
References: <cover.1495990440.git.luto@kernel.org>
	 <c987470279e055d1f1e9d9664f922dbe86b9173d.1495990440.git.luto@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>
Cc: Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>

On Sun, 2017-05-28 at 10:00 -0700, Andy Lutomirski wrote:
> Rather than passing all the contents of flush_tlb_info to
> flush_tlb_others(), pass a pointer to the structure directly. For
> consistency, this also removes the unnecessary cpu parameter from
> uv_flush_tlb_others() to make its signature match the other
> *flush_tlb_others() functions.
> 
> This serves two purposes:
> 
> A - It will dramatically simplify future patches that change struct
> A A A flush_tlb_info, which I'm planning to do.
> 
> A - struct flush_tlb_info is an adequate description of what to do
> A A A for a local flush, too, so by reusing it we can remove duplicated
> A A A code between local and remove flushes in a future patch.
> 
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Nadav Amit <namit@vmware.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> 

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
