Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id JAA01383
	for <linux-mm@kvack.org>; Tue, 12 Nov 2002 09:57:06 -0800 (PST)
Message-ID: <3DD140F1.F4AED387@digeo.com>
Date: Tue, 12 Nov 2002 09:57:05 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [patch/2.4] ll_rw_blk stomping on bh state [Re: kernel BUG at
 journal.c:1732! (2.4.19)]
References: <20021028111357.78197071.nutts@penguinmail.com> <20021112150711.F2837@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Mark Hazell <nutts@penguinmail.com>, adilger@clusterfs.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:
> 
>                 if (maxsector < count || maxsector - count < sector) {
>                         /* Yecch */
>                         bh->b_state &= (1 << BH_Lock) | (1 << BH_Mapped);
> 
> ...
> 
> Folks, just which buffer flags do we want to preserve in this case?
> 

Why do we want to clear any flags in there at all?  To prevent
a storm of error messages from a buffer which has a silly block
number?

If so, how about setting a new state bit which causes subsequent
IO attempts to silently drop the IO on the floor?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
