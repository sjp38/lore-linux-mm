Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 3AEE36B004D
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 01:12:29 -0400 (EDT)
Date: Mon, 23 Apr 2012 07:12:27 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: Weirdness in __alloc_bootmem_node_high
Message-ID: <20120423051227.GB6709@merkur.ravnborg.org>
References: <20120420194309.GA3689@merkur.ravnborg.org> <20120422.152210.1520263792125579554.davem@davemloft.net> <20120422200554.GA6385@merkur.ravnborg.org> <20120422.220054.1961736352806510855.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120422.220054.1961736352806510855.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: yinghai@kernel.org, tj@kernel.org, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Apr 22, 2012 at 10:00:54PM -0400, David Miller wrote:
> 
> So here is a sparc64 conversion to NO_BOOTMEM.
Great!

I looked briefly through the patch - no comments.
I will take a more carefull look tonight.

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
