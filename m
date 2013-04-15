Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id A06DA6B0002
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 12:31:01 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id rr4so2595961pbb.10
        for <linux-mm@kvack.org>; Mon, 15 Apr 2013 09:31:00 -0700 (PDT)
Date: Mon, 15 Apr 2013 09:30:40 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/3] mm: Remove unused parameter of
 pages_correctly_reserved()
Message-ID: <20130415163040.GA2750@kroah.com>
References: <1366019207-27818-1-git-send-email-tangchen@cn.fujitsu.com>
 <1366019207-27818-2-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1366019207-27818-2-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, akpm@linux-foundation.org, wency@cn.fujitsu.com, mgorman@suse.de, tj@kernel.org, liwanp@linux.vnet.ibm.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Mon, Apr 15, 2013 at 05:46:45PM +0800, Tang Chen wrote:
> nr_pages is not used in pages_correctly_reserved().
> So remove it.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Reviewed-by: Wang Shilong <wangsl-fnst@cn.fujitsu.com>
> Reviewed-by: Wen Congyang <wency@cn.fujitsu.com>

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
