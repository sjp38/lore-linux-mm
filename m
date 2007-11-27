Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lARIrnAL028788
	for <linux-mm@kvack.org>; Tue, 27 Nov 2007 13:53:49 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lARIrm3x474668
	for <linux-mm@kvack.org>; Tue, 27 Nov 2007 13:53:49 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lARIrm2n002426
	for <linux-mm@kvack.org>; Tue, 27 Nov 2007 13:53:48 -0500
Subject: Re: [Patch](Resend) mm/sparse.c: Improve the error handling for
	sparse_add_one_section()
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071127022609.GA4164@hacking>
References: <1195507022.27759.146.camel@localhost>
	 <20071123055150.GA2488@hacking> <20071126191316.99CF.Y-GOTO@jp.fujitsu.com>
	 <20071127022609.GA4164@hacking>
Content-Type: text/plain
Date: Tue, 27 Nov 2007 10:53:45 -0800
Message-Id: <1196189625.5764.36.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: WANG Cong <xiyou.wangcong@gmail.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-11-27 at 10:26 +0800, WANG Cong wrote:
> 
> @@ -414,7 +418,7 @@ int sparse_add_one_section(struct zone *
>  out:
>         pgdat_resize_unlock(pgdat, &flags);
>         if (ret <= 0)
> -               __kfree_section_memmap(memmap, nr_pages);
> +               kfree(usemap);
>         return ret;
>  }
>  #endif 

Why did you get rid of the memmap free here?  A bad return from
sparse_init_one_section() indicates that we didn't use the memmap, so it
will leak otherwise.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
