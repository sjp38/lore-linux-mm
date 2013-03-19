From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 2/5] zero-filled pages awareness
Date: Tue, 19 Mar 2013 09:23:16 +0800
Message-ID: <31459.1481154368$1363656237@news.gmane.org>
References: <1363314860-22731-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1363314860-22731-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130319005023.GA19891@kroah.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UHlHK-0003F6-DY
	for glkm-linux-mm-2@m.gmane.org; Tue, 19 Mar 2013 02:23:50 +0100
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 3D2786B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 21:23:25 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 19 Mar 2013 11:15:18 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id B73382CE8051
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 12:23:18 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2J1NEXg57278630
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 12:23:14 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2J1NIhd029688
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 12:23:18 +1100
Content-Disposition: inline
In-Reply-To: <20130319005023.GA19891@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 18, 2013 at 05:50:23PM -0700, Greg Kroah-Hartman wrote:
>On Fri, Mar 15, 2013 at 10:34:17AM +0800, Wanpeng Li wrote:
>> Compression of zero-filled pages can unneccessarily cause internal
>> fragmentation, and thus waste memory. This special case can be
>> optimized.
>> 
>> This patch captures zero-filled pages, and marks their corresponding
>> zcache backing page entry as zero-filled. Whenever such zero-filled
>> page is retrieved, we fill the page frame with zero.
>> 
>> Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>
>This patch applies with a bunch of fuzz, meaning it wasn't made against
>the latest tree, which worries me.  Care to redo it, and the rest of the
>series, and resend it?

Ok, sorry for the confusing, I will do it today, thanks Greg. :-)

Regards,
Wanpeng Li 

>
>thanks,
>
>greg k-h
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
