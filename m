Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5DC196B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 17:26:44 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id c7so21510529wjb.7
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 14:26:44 -0800 (PST)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id g109si2594784wrd.9.2017.02.06.14.26.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Feb 2017 14:26:43 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id E7EA298B1E
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 22:26:42 +0000 (UTC)
Date: Mon, 6 Feb 2017 22:26:42 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm/autonuma: don't use set_pte_at when updating protnone
 ptes
Message-ID: <20170206222642.u2e5ip4h2udaehr4@techsingularity.net>
References: <1486400776-28114-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1486400776-28114-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 06, 2017 at 10:36:16PM +0530, Aneesh Kumar K.V wrote:
> Architectures like ppc64, use privilege access bit to mark pte non accessible.
> This implies that kernel can do a copy_to_user to an address marked for numa fault.
> This also implies that there can be a parallel hardware update for the pte.
> set_pte_at cannot be used in such scenarios. Hence switch the pte
> update to use ptep_get_and_clear and set_pte_at combination.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Yeah, ok. The main thing is that it still avoids doing an unnecessary TLB
flush so

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
