Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id CDD696B00F8
	for <linux-mm@kvack.org>; Fri, 25 May 2012 05:12:47 -0400 (EDT)
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by merlin.infradead.org with esmtps (Exim 4.76 #1 (Red Hat Linux))
	id 1SXqZi-0005UD-Cv
	for linux-mm@kvack.org; Fri, 25 May 2012 09:12:46 +0000
Received: from dhcp-089-099-019-018.chello.nl ([89.99.19.18] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1SXqZi-0000MS-2I
	for linux-mm@kvack.org; Fri, 25 May 2012 09:12:46 +0000
Subject: Re: [PATCH 0/2 v4] Flexible proportions
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1337878751-22942-1-git-send-email-jack@suse.cz>
References: <1337878751-22942-1-git-send-email-jack@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 25 May 2012 11:12:42 +0200
Message-ID: <1337937162.9783.163.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 2012-05-24 at 18:59 +0200, Jan Kara wrote:
>   here is the next iteration of my flexible proportions code. I've addressed
> all Peter's comments. 

Thanks, all I could come up with is comment placement nits and I'll not
go there ;-)

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
