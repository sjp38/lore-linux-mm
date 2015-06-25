Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id AB97F6B0038
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 23:23:49 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so21843006pdb.1
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 20:23:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id u3si18155180pds.41.2015.06.24.20.23.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jun 2015 20:23:48 -0700 (PDT)
Date: Wed, 24 Jun 2015 20:23:41 -0700
From: Darren Hart <dvhart@infradead.org>
Subject: Re: [PATCH] dell-laptop: Fix allocating & freeing SMI buffer page
Message-ID: <20150625032341.GA18285@vmdeb7>
References: <1434876063-13460-1-git-send-email-pali.rohar@gmail.com>
 <1435047079-949-1-git-send-email-pali.rohar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1435047079-949-1-git-send-email-pali.rohar@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Cc: Matthew Garrett <mjg59@srcf.ucam.org>, Michal Hocko <mhocko@suse.cz>, platform-driver-x86@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Tue, Jun 23, 2015 at 10:11:19AM +0200, Pali Rohar wrote:
> This commit fix kernel crash when probing for rfkill devices in dell-laptop
> driver failed. Function free_page() was incorrectly used on struct page *
> instead of virtual address of SMI buffer.
> 
> This commit also simplify allocating page for SMI buffer by using
> __get_free_page() function instead of sequential call of functions
> alloc_page() and page_address().
> 
> Signed-off-by: Pali Rohar <pali.rohar@gmail.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>
> Cc: stable@vger.kernel.org

Queued, thanks Pali.

-- 
Darren Hart
Intel Open Source Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
