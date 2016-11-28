Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D4A706B0038
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:20:37 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 83so227113887pfx.1
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:20:37 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id b34si27718750pld.128.2016.11.28.11.20.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:20:36 -0800 (PST)
Date: Mon, 28 Nov 2016 12:20:35 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 2/6] dax: remove leading space from labels
Message-ID: <20161128192035.GC6637@linux.intel.com>
References: <1479926662-21718-1-git-send-email-ross.zwisler@linux.intel.com>
 <1479926662-21718-3-git-send-email-ross.zwisler@linux.intel.com>
 <20161124091140.GB24138@quack2.suse.cz>
 <CAPcyv4g=4OAskS3x31H5yx0T+suDbpwQpSyDtb+36rwmKCGMng@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4g=4OAskS3x31H5yx0T+suDbpwQpSyDtb+36rwmKCGMng@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Thu, Nov 24, 2016 at 11:42:38AM -0800, Dan Williams wrote:
> On Thu, Nov 24, 2016 at 1:11 AM, Jan Kara <jack@suse.cz> wrote:
> > On Wed 23-11-16 11:44:18, Ross Zwisler wrote:
> >> No functional change.
> >>
> >> As of this commit:
> >>
> >> commit 218dd85887da (".gitattributes: set git diff driver for C source code
> >> files")
> >>
> >> git-diff and git-format-patch both generate diffs whose hunks are correctly
> >> prefixed by function names instead of labels, even if those labels aren't
> >> indented with spaces.
> >
> > Fine by me. I just have some 4 remaining DAX patches (will send them out
> > today) and they will clash with this. So I'd prefer if this happened after
> > they are merged...
> 
> Let's just leave them alone, it's not like this thrash buys us
> anything at this point.  We can just stop including spaces in new
> code.

Honestly I'm not sure which is better.  I understand your argument about not
introducing "thrash" for cleanup like this, but at the same time knowingly
leaving inconsistencies in the code style just because seems...gross?

In any case, sure Jan, if this patch happens lets do it after your remaining
DAX patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
