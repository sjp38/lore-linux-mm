Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id C03C56B006E
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 15:51:16 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fb1so4005635pad.25
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 12:51:16 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id sf2si2363232pac.191.2014.10.16.12.51.15
        for <linux-mm@kvack.org>;
        Thu, 16 Oct 2014 12:51:15 -0700 (PDT)
Date: Thu, 16 Oct 2014 15:51:12 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v11 07/21] dax,ext2: Replace XIP read and write with DAX
 I/O
Message-ID: <20141016195112.GE11522@wil.cx>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-8-git-send-email-matthew.r.wilcox@intel.com>
 <20141016095027.GE19075@thinkos.etherlink>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141016095027.GE19075@thinkos.etherlink>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Oct 16, 2014 at 11:50:27AM +0200, Mathieu Desnoyers wrote:
> > +			if (rw == WRITE) {
> > +				if (!buffer_mapped(bh)) {
> > +					retval = -EIO;
> > +					/* FIXME: fall back to buffered I/O */
> 
> Fallback on buffered I/O would void guarantee about having data stored
> into persistent memory after write returns. Not sure we actually want
> that.

Yeah, I think that comment is just stale.  I can't see a way in which
buffered I/O would succeed after DAX I/O falis.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
