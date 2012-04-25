Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 2E8966B00EC
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 14:14:33 -0400 (EDT)
Received: by dadq36 with SMTP id q36so532004dad.8
        for <linux-mm@kvack.org>; Wed, 25 Apr 2012 11:14:32 -0700 (PDT)
Date: Wed, 25 Apr 2012 11:14:28 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 0/6] zsmalloc: clean up and fix arch dependency
Message-ID: <20120425181428.GA23016@kroah.com>
References: <1335334994-22138-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1335334994-22138-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Apr 25, 2012 at 03:23:08PM +0900, Minchan Kim wrote:
> This patchset has some clean up patches(1-5) and remove 
> set_bit, flush_tlb for portability in [6/6].
> 
> Minchan Kim (6):
>   zsmalloc: use PageFlag macro instead of [set|test]_bit

I've only applied this one patch, so feel free to drop it from your
series when you redo the others for your next round.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
