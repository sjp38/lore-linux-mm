Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 730826B0031
	for <linux-mm@kvack.org>; Sun, 27 Oct 2013 22:37:45 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id r10so6411375pdi.18
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 19:37:45 -0700 (PDT)
Received: from psmtp.com ([74.125.245.161])
        by mx.google.com with SMTP id yj4si11545374pac.253.2013.10.27.19.37.43
        for <linux-mm@kvack.org>;
        Sun, 27 Oct 2013 19:37:44 -0700 (PDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 28 Oct 2013 08:07:39 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 5BFBC1258055
	for <linux-mm@kvack.org>; Mon, 28 Oct 2013 08:08:14 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9S2bXOb34930924
	for <linux-mm@kvack.org>; Mon, 28 Oct 2013 08:07:33 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9S2batL028528
	for <linux-mm@kvack.org>; Mon, 28 Oct 2013 08:07:36 +0530
Date: Mon, 28 Oct 2013 10:37:35 +0800
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] percpu: merge two loops when setting up group info
Message-ID: <20131028023734.GA15642@weiyang.vnet.ibm.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
References: <1382345893-6644-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <1382345893-6644-2-git-send-email-weiyang@linux.vnet.ibm.com>
 <20131027123542.GK14934@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131027123542.GK14934@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Oct 27, 2013 at 08:35:42AM -0400, Tejun Heo wrote:
>On Mon, Oct 21, 2013 at 04:58:12PM +0800, Wei Yang wrote:
>> There are two loops setting up the group info of pcpu_alloc_info. They share
>> the same logic, so merge them could be time efficient when there are many
>> groups.
>> 
>> This patch merge these two loops into one.
>
>It *looks* correct to me but I'd rather not change this unless you can
>show me this actually matters, which I find extremely doubtful given
>nr_groups would be in the order of few thousands even on an extremely
>large machine.

Tejun, thanks for your review and comments.

I agree with you that the nr_groups won't be very large, which means it will
not bring many benefits.

This is just a small code refine. If you don't like it, just drop it :-)

>
>Thanks.
>
>-- 
>tejun

-- 
Richard Yang
Help you, Help me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
