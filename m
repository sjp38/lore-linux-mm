Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 18F4B6B0006
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 16:13:23 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id d46so1517523wer.16
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 13:13:21 -0700 (PDT)
MIME-Version: 1.0
Reply-To: konrad@darnok.org
In-Reply-To: <1364984183-9711-2-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1364984183-9711-1-git-send-email-liwanp@linux.vnet.ibm.com> <1364984183-9711-2-git-send-email-liwanp@linux.vnet.ibm.com>
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Date: Wed, 3 Apr 2013 16:13:01 -0400
Message-ID: <CAPbh3ru54LVA1gVqH7seXWgAviz-dbiFKfXC3RVHZqUbk9=y0Q@mail.gmail.com>
Subject: Re: [PATCH v6 1/3] staging: zcache: fix static variables defined in
 debug.h but used in mutiple C files
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Fengguang Wu <fengguang.wu@intel.com>

On Wed, Apr 3, 2013 at 6:16 AM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
> After commit 95bdaee214 ("zcache: Move debugfs code out of zcache-main.c file")
> be merged, most of knods in zcache debugfs just export zero since these variables
> are defined in debug.h but are in use in multiple C files zcache-main.c and debug.c,
> in this case variables can't be treated as shared variables.
>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
