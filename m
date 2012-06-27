Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 0FAD36B005C
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 00:47:30 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Wed, 27 Jun 2012 10:17:27 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5R4lON310486238
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 10:17:24 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5RAHuhW015192
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 20:17:57 +1000
Message-ID: <4FEA905A.4070207@linux.vnet.ibm.com>
Date: Wed, 27 Jun 2012 12:47:22 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/9] zcache: fix refcount leak
References: <4FE97792.9020807@linux.vnet.ibm.com> <4FE977AA.2090003@linux.vnet.ibm.com> <20120626223651.GB6561@localhost.localdomain>
In-Reply-To: <20120626223651.GB6561@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org

On 06/27/2012 06:36 AM, Konrad Rzeszutek Wilk wrote:
> On Tue, Jun 26, 2012 at 04:49:46PM +0800, Xiao Guangrong wrote:
>> In zcache_get_pool_by_id, the refcount of zcache_host is not increased, but
>> it is always decreased in zcache_put_pool
> 
> All of the patches (1-9) look good to me, so please also
> affix 'Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>'.
> 

Thank you, Konrad!

Greg, need i repost this patchset with Konrad's Reviewed-by?

> You also might want to send this patch series with Greg KH being
> on the To line- not just as CC -as he is the one committing the
> patches in the git tree.

Yes, i did it in the [PATCH 0/9], but i do not know why it was missed
in mm list, the later patches replied this patch, so my mail is in
the To line-. :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
