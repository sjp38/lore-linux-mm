Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 7F0EF6B0008
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 17:45:23 -0500 (EST)
Message-ID: <51030AFA.104@redhat.com>
Date: Fri, 25 Jan 2013 17:45:14 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] swap: fix "add per-partition lock for swapfile" for nommu
References: <201301252218.07296.arnd@arndb.de>
In-Reply-To: <201301252218.07296.arnd@arndb.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Shaohua Li <shli@fusionio.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On 01/25/2013 05:18 PM, Arnd Bergmann wrote:
> The patch "swap: add per-partition lock for swapfile" made the
> nr_swap_pages variable unaccessible but forgot to change the
> mm/nommu.c file that uses it. This does the trivial conversion
> to let us build nommu kernels again
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
