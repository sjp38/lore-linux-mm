Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7FFF66B02CC
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 17:21:08 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id g23so9832382wme.4
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:21:08 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id fu10si30402803wjc.118.2016.11.15.14.21.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 14:21:07 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id u144so4776843wmu.0
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:21:07 -0800 (PST)
Date: Wed, 16 Nov 2016 01:21:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 09/21] mm: Factor out functionality to finish page faults
Message-ID: <20161115222105.GI23021@node>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-10-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478233517-3571-10-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Nov 04, 2016 at 05:25:05AM +0100, Jan Kara wrote:
> Introduce function finish_fault() as a helper function for finishing
> page faults. It is rather thin wrapper around alloc_set_pte() but since
> we'd want to call this from DAX code or filesystems, it is still useful
> to avoid some boilerplate code.
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
