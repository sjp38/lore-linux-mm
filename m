Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1DE226B006E
	for <linux-mm@kvack.org>; Mon, 14 Nov 2011 15:55:22 -0500 (EST)
Date: Mon, 14 Nov 2011 15:53:24 -0500
From: Andrew Watts <akwatts@ymail.com>
Subject: Re: [OOPS]: Kernel 3.1 (ext3?)
Message-ID: <20111114205304.GA5542@zeus>
References: <20111110132929.GA11417@zeus>
 <20111114195352.GB17328@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111114195352.GB17328@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org

On Mon, Nov 14, 2011 at 08:53:52PM +0100, Jan Kara wrote:
>   Hmm, the report is missing a line (top one) saying why the kernel
> actually crashed. Can you add that?
> 
>   Also it seems you are using SLUB allocator, right? This seems like a
> problem there so adding some CCs.

Hi Jan.

Unfortunately, the oops trace is a transcription of all that was left on
my screen. I hope that can provide enough clues into what is going on.

Yes, I use the SLUB allocator.

Thank you for your reply and for adding revelant cc's.

~ Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
