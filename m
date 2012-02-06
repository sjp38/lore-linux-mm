Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 2BD7E6B13F0
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 10:37:15 -0500 (EST)
Date: Mon, 6 Feb 2012 23:25:00 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/3] move page-types.c from Documentation to tools/vm
Message-ID: <20120206152500.GA5687@localhost>
References: <20120205081542.GA2245@darkstar.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120205081542.GA2245@darkstar.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, xiyou.wangcong@gmail.com, penberg@kernel.org, cl@linux.com

On Sun, Feb 05, 2012 at 04:15:42PM +0800, Dave Young wrote:
> tools/ is the better place for vm tools which are used by many people.
> Moving them to tools also make them open to more users instead of hide in
> Documentation folder.
> 
> This patch move page-types.c to tools/vm/page-types.c
> Also add Makefile in tools/vm and fix two coding style problems of below:
> a. change const arrary to 'const char * const'
> b. change a space to tab for indent
> 
> Signed-off-by: Dave Young <dyoung@redhat.com>

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
