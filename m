Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4EB896B00CC
	for <linux-mm@kvack.org>; Fri,  7 Jan 2011 17:27:59 -0500 (EST)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p07MRvCs026103
	for <linux-mm@kvack.org>; Fri, 7 Jan 2011 14:27:57 -0800
Received: from pxi11 (pxi11.prod.google.com [10.243.27.11])
	by hpaq14.eem.corp.google.com with ESMTP id p07MRs4w013324
	for <linux-mm@kvack.org>; Fri, 7 Jan 2011 14:27:55 -0800
Received: by pxi11 with SMTP id 11so4084008pxi.35
        for <linux-mm@kvack.org>; Fri, 07 Jan 2011 14:27:54 -0800 (PST)
Date: Fri, 7 Jan 2011 14:27:51 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 1/2] Add explanation about min_free_kbytes to clarify
 its effect
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9C3A30A297@USINDEVS02.corp.hds.com>
Message-ID: <alpine.DEB.2.00.1101071426010.23818@chino.kir.corp.google.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9C3A30A295@USINDEVS02.corp.hds.com> <65795E11DBF1E645A09CEC7EAEE94B9C3A30A297@USINDEVS02.corp.hds.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Satoru Moriya <satoru.moriya@hds.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Randy Dunlap <rdunlap@xenotime.net>, dle-develop@lists.sourceforge.net, Seiji Aguchi <seiji.aguchi@hds.com>
List-ID: <linux-mm.kvack.org>

On Fri, 7 Jan 2011, Satoru Moriya wrote:

> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 30289fa..e10b279 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -349,7 +349,8 @@ min_free_kbytes:
>  
>  This is used to force the Linux VM to keep a minimum number
>  of kilobytes free.  The VM uses this number to compute a
> -watermark[WMARK_MIN] value for each lowmem zone in the system.
> +watermark[WMARK_MIN] for each lowmem zone and
> +watermark[WMARK_LOW/WMARK_HIGH] for each zone in the system.
>  Each lowmem zone gets a number of reserved free pages based
>  proportionally on its size.
>  

WMARK_MIN is changed for all zones.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
