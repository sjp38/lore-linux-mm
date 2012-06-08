Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 65DD26B0070
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 03:23:42 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2429345dak.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 00:23:41 -0700 (PDT)
Message-ID: <4FD1A872.7070906@vflare.org>
Date: Fri, 08 Jun 2012 00:23:30 -0700
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH] zram: fix random data read
References: <1339137567-29656-1-git-send-email-minchan@kernel.org> <1339137567-29656-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1339137567-29656-2-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Jerome Marchand <jmarchan@redhat.com>

On 06/07/2012 11:39 PM, Minchan Kim wrote:

> fd1a30de makes a bug that it uses (struct page *) as zsmalloc's handle
> although it's a uncompressed page so that it can access random page,
> return random data or even crashed by get_first_page in zs_map_object.
> 
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Cc: Jerome Marchand <jmarchan@redhat.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  drivers/staging/zram/zram_drv.c |   15 ++++++++-------
>  1 file changed, 8 insertions(+), 7 deletions(-)
> 


Great catch! The problem goes away after your next patch for using
zsmalloc for all the cases, still this fix can never hurt.

Acked-by: Nitin Gupta <ngupta@vflare.org>


Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
