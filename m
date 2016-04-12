Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id CB7286B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 11:53:50 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id u206so34110513wme.1
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 08:53:50 -0700 (PDT)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id e19si24511652wmc.60.2016.04.12.08.53.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 08:53:49 -0700 (PDT)
Received: by mail-wm0-x231.google.com with SMTP id l6so194027163wml.1
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 08:53:49 -0700 (PDT)
Date: Tue, 12 Apr 2016 16:53:47 +0100
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [PATCH 03/19] x86/efi: get rid of superfluous __GFP_REPEAT
Message-ID: <20160412155347.GF2829@codeblueprint.co.uk>
References: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
 <1460372892-8157-4-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1460372892-8157-4-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org

On Mon, 11 Apr, at 01:07:56PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> __GFP_REPEAT has a rather weak semantic but since it has been introduced
> around 2.6.12 it has been ignored for low order allocations.
> 
> efi_alloc_page_tables uses __GFP_REPEAT but it allocates an order-0
> page. This means that this flag has never been actually useful here
> because it has always been used only for PAGE_ALLOC_COSTLY requests.
> 
> Cc: Matt Fleming <matt@codeblueprint.co.uk>
> Cc: linux-arch@vger.kernel.org
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  arch/x86/platform/efi/efi_64.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Looks fine. I suspect I copied it from other pgtable creation code,

Reviewed-by: Matt Fleming <matt@codeblueprint.co.uk>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
