Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A17E1900001
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 01:55:24 -0400 (EDT)
Date: Tue, 26 Apr 2011 13:55:21 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: readahead and oom
Message-ID: <20110426055521.GA18473@localhost>
References: <BANLkTin8mE=DLWma=U+CdJaQW03X2M2W1w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTin8mE=DLWma=U+CdJaQW03X2M2W1w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <hidave.darkstar@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Apr 26, 2011 at 01:49:25PM +0800, Dave Young wrote:
> Hi,
> 
> When memory pressure is high, readahead could cause oom killing.
> IMHO we should stop readaheading under such circumstancesa??If it's true
> how to fix it?

Good question. Before OOM there will be readahead thrashings, which
can be addressed by this patch:

http://lkml.org/lkml/2010/2/2/229

However there seems no much interest on that feature.. I can separate
that out and resubmit it standalone if necessary.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
