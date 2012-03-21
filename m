Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 835E76B004A
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 00:53:42 -0400 (EDT)
Date: Tue, 20 Mar 2012 21:56:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC]swap: don't do discard if no discard option added
Message-Id: <20120320215647.f1268b05.akpm@linux-foundation.org>
In-Reply-To: <CANejiEUyPSNQ7q85ZDz-B3iHikHLgZLBNOF-p4evkxjGo5+M0g@mail.gmail.com>
References: <4F68795E.9030304@kernel.org>
	<alpine.LSU.2.00.1203202019140.1842@eggly.anvils>
	<CANejiEUyPSNQ7q85ZDz-B3iHikHLgZLBNOF-p4evkxjGo5+M0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Holger Kiehl <Holger.Kiehl@dwd.de>, "Martin K. Petersen" <martin.petersen@oracle.com>, linux-mm@kvack.org

On Wed, 21 Mar 2012 12:31:47 +0800 Shaohua Li <shli@kernel.org> wrote:

>  But on
> the other hand, if user doesn't explictly enable discard, why enable
> it? Like fs, we didn't do runtime discard and only run trim occasionally
> since discard is slow.

This.  Neither the swapon manpage nor the SWAP_FLAG_DISCARD comment nor
.c code comments nor the 339944663 changelog explain why we do a single
discard at swapon() time and then never again.

It sure *looks* like a bug.  If it isn't then some explanation is sorely
needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
