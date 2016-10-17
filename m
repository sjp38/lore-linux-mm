Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 876276B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 13:38:05 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u84so201698075pfj.6
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 10:38:05 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id z21si11996808pgf.155.2016.10.17.10.38.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 10:38:04 -0700 (PDT)
Date: Mon, 17 Oct 2016 11:38:03 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 09/20] mm: Factor out functionality to finish page faults
Message-ID: <20161017173803.GA6104@linux.intel.com>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-10-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474992504-20133-10-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 27, 2016 at 06:08:13PM +0200, Jan Kara wrote:
> Introduce function finish_fault() as a helper function for finishing
> page faults. It is rather thin wrapper around alloc_set_pte() but since
> we'd want to call this from DAX code or filesystems, it is still useful
> to avoid some boilerplate code.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
