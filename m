Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 573226B05E5
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 06:44:56 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id z72-v6so11149167ede.14
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 03:44:56 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m21-v6si1737966ejc.186.2018.11.08.03.44.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 03:44:55 -0800 (PST)
Subject: Re: [PATCH v3 1/4] mm: reference totalram_pages and managed_pages
 once per function
References: <1541665398-29925-1-git-send-email-arunks@codeaurora.org>
 <1541665398-29925-2-git-send-email-arunks@codeaurora.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <bceb1841-885f-a35a-b4a0-522f588af956@suse.cz>
Date: Thu, 8 Nov 2018 12:44:53 +0100
MIME-Version: 1.0
In-Reply-To: <1541665398-29925-2-git-send-email-arunks@codeaurora.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>, akpm@linux-foundation.org, keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, mhocko@kernel.org, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: getarunks@gmail.com

On 11/8/18 9:23 AM, Arun KS wrote:
> This patch is in preparation to a later patch which converts totalram_pages
> and zone->managed_pages to atomic variables. Please note that re-reading
> the value might lead to a different value and as such it could lead to
> unexpected behavior. There are no known bugs as a result of the current code
> but it is better to prevent from them in principle.

..., which will happen after the atomic conversion in the next patch.

> Signed-off-by: Arun KS <arunks@codeaurora.org>
> Reviewed-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Acked-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
