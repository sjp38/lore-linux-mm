Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AE94B6B006E
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 14:27:42 -0400 (EDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 1 Nov 2011 12:23:27 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pA1ICRHH118320
	for <linux-mm@kvack.org>; Tue, 1 Nov 2011 12:22:49 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pA1HUQtP031809
	for <linux-mm@kvack.org>; Tue, 1 Nov 2011 11:30:26 -0600
Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4E738B81.2070005@vflare.org>
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com>
	 <20110909203447.GB19127@kroah.com> <4E6ACE5B.9040401@vflare.org>
	 <4E6E18C6.8080900@linux.vnet.ibm.com> <4E6EB802.4070109@vflare.org>
	 <4E6F7DA7.9000706@linux.vnet.ibm.com> <4E6FC8A1.8070902@vflare.org>
	 <4E72284B.2040907@linux.vnet.ibm.com>  <4E738B81.2070005@vflare.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 01 Nov 2011 10:30:15 -0700
Message-ID: <1320168615.15403.80.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg KH <greg@kroah.com>, gregkh@suse.de, devel@driverdev.osuosl.org, dan.magenheimer@oracle.com, cascardo@holoscopio.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com

On Fri, 2011-09-16 at 13:46 -0400, Nitin Gupta wrote:
> I think replacing allocator every few weeks isn't a good idea. So, I
> guess better would be to let me work for about 2 weeks and try the slab
> based approach.  If nothing works out in this time, then maybe xcfmalloc
> can be integrated after further testing.

Hi Nitin,

It's been about six weeks. :)

Can we talk about putting xcfmalloc() in staging now?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
