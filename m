From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] mm/slab: Sharing s_next and s_stop between slab and
 slub
Date: Tue, 2 Jul 2013 07:49:34 +0800
Message-ID: <11918.6283242472$1372722593@news.gmane.org>
References: <1372069394-26167-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1372069394-26167-2-git-send-email-liwanp@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1306241421560.25343@chino.kir.corp.google.com>
 <0000013f9aeb70c6-f6dad22c-bb88-4313-8602-538a3f5cedf5-000000@email.amazonses.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Utnqq-00017N-K8
	for glkm-linux-mm-2@m.gmane.org; Tue, 02 Jul 2013 01:49:44 +0200
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 4F0216B0032
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 19:49:42 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 2 Jul 2013 05:10:43 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 64DFBE0054
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 05:19:14 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r61NnVhu24903816
	for <linux-mm@kvack.org>; Tue, 2 Jul 2013 05:19:31 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r61NnYWa031828
	for <linux-mm@kvack.org>; Mon, 1 Jul 2013 23:49:34 GMT
Content-Disposition: inline
In-Reply-To: <0000013f9aeb70c6-f6dad22c-bb88-4313-8602-538a3f5cedf5-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 01, 2013 at 03:48:09PM +0000, Christoph Lameter wrote:
>On Mon, 24 Jun 2013, David Rientjes wrote:
>
>> On Mon, 24 Jun 2013, Wanpeng Li wrote:
>>
>> > This patch shares s_next and s_stop between slab and slub.
>> >
>>
>> Just about the entire kernel includes slab.h, so I think you'll need to
>> give these slab-specific names instead of exporting "s_next" and "s_stop"
>> to everybody.
>
>He put the export into mm/slab.h. The headerfile is only included by
>mm/sl?b.c .

So I think this patch is ok, David? 

Regards,
Wanpeng Li 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
