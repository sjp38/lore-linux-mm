Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 337016B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 10:25:03 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 20 Jun 2013 10:25:02 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 30CA838C8065
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 10:24:59 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5KENibW53280940
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 10:23:44 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5KENf25000372
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 10:23:44 -0400
Date: Thu, 20 Jun 2013 09:23:28 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCHv13 3/4] zswap: add to mm/
Message-ID: <20130620142328.GA9461@cerebellum>
References: <1370291585-26102-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1370291585-26102-4-git-send-email-sjenning@linux.vnet.ibm.com>
 <CAA_GA1eWFYDxp3gEdWzajVP4jMpmJbt=oWBZYqZEQjndU=s_Qg@mail.gmail.com>
 <20130620023750.GA1194@cerebellum>
 <CAA_GA1c8cH1fu9jHk8evKZvK-gpQ+c8NEp5=_jDLKPcMbG_ufA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA_GA1c8cH1fu9jHk8evKZvK-gpQ+c8NEp5=_jDLKPcMbG_ufA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org

On Thu, Jun 20, 2013 at 05:42:04PM +0800, Bob Liu wrote:
> > Just made a mmtests run of my own and got very different results:
> >
> 
> It's strange, I'll update to rc6 and try again.
> By the way, are you using 824 hardware compressor instead of lzo?

My results where using lzo software compression.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
