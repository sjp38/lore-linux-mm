Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 4CDCF6B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 22:10:20 -0400 (EDT)
Date: Wed, 25 Apr 2012 10:10:11 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH RFC v2 0/1] Flexible proportions
Message-ID: <20120425021011.GA5600@localhost>
References: <1335285033-7347-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1335285033-7347-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>

Hi Jan,

>   So my plan, if people are happy with the new proportion code, would be to
> switch at least bdi writeout proportion to the new code. I can also check
> other users to see whether it would make sense for them to switch. So what
> do people think?

When you get ready with the full patchset, I would be very interested
in watching how it performs in the various JBOD tests :-)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
