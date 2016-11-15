Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 591A46B02C9
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 17:14:47 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id i131so9675960wmf.3
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:14:47 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id 67si4654422wmj.100.2016.11.15.14.14.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 14:14:46 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id g23so4747770wme.1
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:14:46 -0800 (PST)
Date: Wed, 16 Nov 2016 01:14:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 07/21] mm: Add orig_pte field into vm_fault
Message-ID: <20161115221444.GG23021@node>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-8-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478233517-3571-8-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Nov 04, 2016 at 05:25:03AM +0100, Jan Kara wrote:
> Add orig_pte field to vm_fault structure to allow ->page_mkwrite
> handlers to fully handle the fault. This also allows us to save some
> passing of extra arguments around.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
