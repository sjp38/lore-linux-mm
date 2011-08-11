Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 853A4900137
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 04:25:32 -0400 (EDT)
Date: Thu, 11 Aug 2011 09:25:28 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: MMTests 0.01
Message-ID: <20110811082528.GA4844@suse.de>
References: <20110804143844.GQ19099@suse.de>
 <1312526302.37390.YahooMailNeo@web162009.mail.bf1.yahoo.com>
 <20110805080133.GS19099@suse.de>
 <1313040359.41174.YahooMailNeo@web162012.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1313040359.41174.YahooMailNeo@web162012.mail.bf1.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Agarwal <pintu_agarwal@yahoo.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Aug 10, 2011 at 10:25:59PM -0700, Pintu Agarwal wrote:
> Dear Mel Gorman,
>  
> I found one problem in MMTests0.01/fraganalysis/Makefile
>  
> When I did "make install" here, I got the following error:
> install: cannot stat `record-buddyinfo': No such file or directory
> make: *** [install-script] Error 1
>  
> I think the following line in makefile need to be corrected:
> #####INSTALL_SCRIPT = pagealloc-extfrag show-buddyinfo slab-intfrag record-buddyinfo
> 
> INSTALL_SCRIPT = pagealloc-extfrag show-buddyinfo slab-intfrag record-extfrag
>  
> I corrected this and it works now.
>  

This is the correct fix. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
