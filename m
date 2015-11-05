Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id F081282F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 12:29:53 -0500 (EST)
Received: by wicfv8 with SMTP id fv8so14276373wic.0
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 09:29:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 193si13865865wmx.83.2015.11.05.09.29.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 Nov 2015 09:29:52 -0800 (PST)
Subject: Re: [PATCH 1/12] mm Documentation: undoc non-linear vmas
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
 <alpine.LSU.2.11.1510182144210.2481@eggly.anvils>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <563B920E.2000201@suse.cz>
Date: Thu, 5 Nov 2015 18:29:50 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1510182144210.2481@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org

On 10/19/2015 06:45 AM, Hugh Dickins wrote:
> While updating some mm Documentation, I came across a few straggling
> references to the non-linear vmas which were happily removed in v4.0.
> Delete them.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
