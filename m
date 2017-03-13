Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 359136B0422
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 01:21:47 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id e5so283376084pgk.1
        for <linux-mm@kvack.org>; Sun, 12 Mar 2017 22:21:47 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b21si10439321pgj.261.2017.03.12.22.21.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Mar 2017 22:21:46 -0700 (PDT)
Date: Mon, 13 Mar 2017 08:21:13 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] mm: mark gup_pud_range as unused
Message-ID: <20170313052113.4mgqf7a6vsfyeocg@black.fi.intel.com>
References: <20170313035837.29719-1-chris.packham@alliedtelesis.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170313035837.29719-1-chris.packham@alliedtelesis.co.nz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Packham <chris.packham@alliedtelesis.co.nz>
Cc: linux-mm@kvack.org, mhocko@suse.com, linux-kernel@vger.kernel.org

On Mon, Mar 13, 2017 at 04:58:37PM +1300, Chris Packham wrote:
> The last caller to gup_pud_range was removed in commit c2febafc6773
> ("mm: convert generic code to 5-level paging"). Mark it as unused to
> silence a warning from gcc.
> 
> Signed-off-by: Chris Packham <chris.packham@alliedtelesis.co.nz>
> ---
> I saw this warning when compiling 4.11-rc2 with -Werror. An equally valid fix
> would be to remove the function entirely but I went for the less invasive
> approach.

Thanks for report. But real fix is to call gup_pud_range() from
gup_p4d_range(), not itself.

I'll post a fix.
Reported-by: Chris Packham <chris.packham@alliedtelesis.co.nz>
Reported-by: Chris Packham <chris.packham@alliedtelesis.co.nz>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
