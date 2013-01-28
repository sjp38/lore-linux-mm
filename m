Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 921B86B0007
	for <linux-mm@kvack.org>; Sun, 27 Jan 2013 22:42:30 -0500 (EST)
Received: by mail-vc0-f177.google.com with SMTP id m18so1609136vcm.36
        for <linux-mm@kvack.org>; Sun, 27 Jan 2013 19:42:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1359135978-15119-4-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1359135978-15119-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<1359135978-15119-4-git-send-email-sjenning@linux.vnet.ibm.com>
Date: Mon, 28 Jan 2013 12:42:29 +0900
Message-ID: <CAEwNFnDHLgcBt81ZWZqrNSn2ctu86N6Y3JbgqoKVNuq85zU1nw@mail.gmail.com>
Subject: Re: [PATCH 3/4] staging: zsmalloc: add page alloc/free callbacks
From: Minchan Kim <minchan@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Sat, Jan 26, 2013 at 2:46 AM, Seth Jennings
<sjenning@linux.vnet.ibm.com> wrote:
> This patch allows users of zsmalloc to register the
> allocation and free routines used by zsmalloc to obtain
> more pages for the memory pool.  This allows the user
> more control over zsmalloc pool policy and behavior.
>
> If the user does not wish to control this, alloc_page() and
> __free_page() are used by default.
>
> Acked-by: Nitin Gupta <ngupta@vflare.org>
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
