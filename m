Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 99FEA6B02CF
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 17:22:05 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id s63so9457013wms.7
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:22:05 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id hm2si27813132wjb.167.2016.11.15.14.22.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 14:22:04 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id m203so4747370wma.3
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:22:04 -0800 (PST)
Date: Wed, 16 Nov 2016 01:22:01 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 10/21] mm: Move handling of COW faults into DAX code
Message-ID: <20161115222201.GJ23021@node>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-11-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478233517-3571-11-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Nov 04, 2016 at 05:25:06AM +0100, Jan Kara wrote:
> Move final handling of COW faults from generic code into DAX fault
> handler. That way generic code doesn't have to be aware of peculiarities
> of DAX locking so remove that knowledge and make locking functions
> private to fs/dax.c.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

On core-mm bits:

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
