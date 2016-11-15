Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 93F7B6B02DC
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 17:42:08 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g23so10134275wme.4
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:42:08 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id r3si1735568wmd.81.2016.11.15.14.42.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 14:42:07 -0800 (PST)
Received: by mail-wm0-x231.google.com with SMTP id a197so199082866wmd.0
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:42:07 -0800 (PST)
Date: Wed, 16 Nov 2016 01:42:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 14/21] mm: Use vmf->page during WP faults
Message-ID: <20161115224205.GN23021@node>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-15-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478233517-3571-15-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Nov 04, 2016 at 05:25:10AM +0100, Jan Kara wrote:
> So far we set vmf->page during WP faults only when we needed to pass it
> to the ->page_mkwrite handler. Set it in all the cases now and use that
> instead of passing page pointer explicitly around.
> 
> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Signed-off-by: Jan Kara <jack@suse.cz>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
