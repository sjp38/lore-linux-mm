Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 46EE66B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 20:46:49 -0400 (EDT)
Received: by qafl39 with SMTP id l39so493472qaf.9
        for <linux-mm@kvack.org>; Wed, 30 May 2012 17:46:48 -0700 (PDT)
Date: Wed, 30 May 2012 20:46:44 -0400
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [PATCH 2/2 v2] zram: clean up handle
Message-ID: <20120531004643.GB401@localhost.localdomain>
References: <1337737402-16543-1-git-send-email-minchan@kernel.org>
 <1337737402-16543-2-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1337737402-16543-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>

On Wed, May 23, 2012 at 10:43:22AM +0900, Minchan Kim wrote:
> zram's handle variable can store handle of zsmalloc in case of
> compressing efficiently. Otherwise, it stores point of page descriptor.
> This patch clean up the mess by union struct.
> 
> changelog
>   * from v1
> 	- none(new add in v2)
> 
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>

Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Thanks for doing this!
> Signed-off-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
