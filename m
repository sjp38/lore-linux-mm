Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 816A06B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 17:24:49 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id a8so367323312pfg.0
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 14:24:49 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id p2si1860316pge.244.2016.12.01.14.24.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 14:24:48 -0800 (PST)
Date: Thu, 1 Dec 2016 15:24:47 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 5/6] dax: Call ->iomap_begin without entry lock during
 dax fault
Message-ID: <20161201222447.GB13739@linux.intel.com>
References: <1479980796-26161-1-git-send-email-jack@suse.cz>
 <1479980796-26161-6-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479980796-26161-6-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Johannes Weiner <hannes@cmpxchg.org>

On Thu, Nov 24, 2016 at 10:46:35AM +0100, Jan Kara wrote:
> Currently ->iomap_begin() handler is called with entry lock held. If the
> filesystem held any locks between ->iomap_begin() and ->iomap_end()
> (such as ext4 which will want to hold transaction open), this would cause
> lock inversion with the iomap_apply() from standard IO path which first
> calls ->iomap_begin() and only then calls ->actor() callback which grabs
> entry locks for DAX.

I don't see the dax_iomap_actor() grabbing any entry locks for DAX?  Is this
an issue currently, or are you just trying to make the code consistent so we
don't run into issues in the future?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
