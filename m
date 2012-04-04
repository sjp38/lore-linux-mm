Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id DB1966B00EC
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 13:00:07 -0400 (EDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 4 Apr 2012 11:00:06 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 46CA11FF0060
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 10:59:29 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q34Gwp7f261688
	for <linux-mm@kvack.org>; Wed, 4 Apr 2012 10:58:53 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q34GwKsG022260
	for <linux-mm@kvack.org>; Wed, 4 Apr 2012 10:58:20 -0600
Message-ID: <4F7C7DA6.8000406@linux.vnet.ibm.com>
Date: Wed, 04 Apr 2012 11:58:14 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Frontswap feedback from LSF/MM and patches
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

Dan,

I know you presented at LSF/MM.  I was wondering if you'd could
give a quick summary of any feedback you received regarding frontswap,
for those of us that were not there.

Konard,

Can you post the latest frontswap patches to the list since the
last post was v10 back in Sept 2011
(https://lkml.org/lkml/2011/9/15/367) and those patches no longer
apply cleanly.  I know you have them in your git repo, but
I think they need to be on the list too.

Thanks
--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
