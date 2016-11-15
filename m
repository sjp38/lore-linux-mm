Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 31BB26B02CB
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 17:21:03 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id i131so9770953wmf.3
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:21:03 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id p144si4701908wme.14.2016.11.15.14.21.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 14:21:02 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id g23so4795191wme.1
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:21:01 -0800 (PST)
Date: Wed, 16 Nov 2016 01:20:55 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 08/21] mm: Allow full handling of COW faults in ->fault
 handlers
Message-ID: <20161115222055.GH23021@node>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-9-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478233517-3571-9-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Nov 04, 2016 at 05:25:04AM +0100, Jan Kara wrote:
> To allow full handling of COW faults add memcg field to struct vm_fault
> and a return value of ->fault() handler meaning that COW fault is fully
> handled and memcg charge must not be canceled. This will allow us to
> remove knowledge about special DAX locking from the generic fault code.
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
