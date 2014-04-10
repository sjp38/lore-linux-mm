Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id EEB6E6B0038
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 10:26:31 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id bj1so4053614pad.30
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 07:26:31 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id tt4si2323513pac.21.2014.04.10.07.26.30
        for <linux-mm@kvack.org>;
        Thu, 10 Apr 2014 07:26:31 -0700 (PDT)
Date: Thu, 10 Apr 2014 10:26:25 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v7 17/22] Get rid of most mentions of XIP in ext2
Message-ID: <20140410142625.GK5727@linux.intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <0b13a744db9bfca33938bc1576f7eb7bfc9c41c2.1395591795.git.matthew.r.wilcox@intel.com>
 <20140409100435.GJ32103@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140409100435.GJ32103@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 09, 2014 at 12:04:35PM +0200, Jan Kara wrote:
> On Sun 23-03-14 15:08:43, Matthew Wilcox wrote:
> > The only remaining usage is userspace's 'xip' option.
>   Looks good. You can add:
> Reviewed-by: Jan Kara <jack@suse.cz>

I've been thinking about this patch, and I'm not happy with it any more :-)

I want to migrate people away from using 'xip' to 'dax' without breaking
anybody's scripts.  So I'm thinking about adding a new 'dax' option and
having the 'xip' option print a warning and force-enable the 'dax' option.
That way people who might have scripts to look for 'xip' in /proc/mounts
won't break.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
