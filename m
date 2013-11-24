Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1F26B0035
	for <linux-mm@kvack.org>; Sat, 23 Nov 2013 20:49:16 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id rq2so3391544pbb.30
        for <linux-mm@kvack.org>; Sat, 23 Nov 2013 17:49:15 -0800 (PST)
Received: from e28smtp05.in.ibm.com (e28smtp05.in.ibm.com. [122.248.162.5])
        by mx.google.com with ESMTPS id cx4si23814779pbc.89.2013.11.23.17.49.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 23 Nov 2013 17:49:14 -0800 (PST)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Sun, 24 Nov 2013 07:19:10 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 07230394003F
	for <linux-mm@kvack.org>; Sun, 24 Nov 2013 07:19:07 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAO1n0CZ38600796
	for <linux-mm@kvack.org>; Sun, 24 Nov 2013 07:19:01 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rAO1n4oj002337
	for <linux-mm@kvack.org>; Sun, 24 Nov 2013 07:19:04 +0530
Date: Sun, 24 Nov 2013 09:48:58 +0800
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] percpu: stop the loop when a cpu belongs to a new
 group
Message-ID: <20131124014858.GA10185@weiyang.vnet.ibm.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
References: <1382345893-6644-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <20131027123008.GJ14934@mtj.dyndns.org>
 <20131028030055.GC15642@weiyang.vnet.ibm.com>
 <20131028113120.GB11541@mtj.dyndns.org>
 <20131028151746.GA7548@weiyang.vnet.ibm.com>
 <20131120030056.GA15273@weiyang.vnet.ibm.com>
 <20131120055121.GA13754@mtj.dyndns.org>
 <20131122230400.GG8981@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131122230400.GG8981@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Nov 22, 2013 at 06:04:00PM -0500, Tejun Heo wrote:
>Hello,
>
>On Wed, Nov 20, 2013 at 12:51:21AM -0500, Tejun Heo wrote:
>> The patch is just extremely marginal.  Ah well... why not?  I'll apply
>> it once -rc1 drops.
>
>So, I was about to apply this patch but decided against it.  It
>doesn't really make anything better and the code looks worse
>afterwards.

Ok, that's fine. Maybe we could find a better way :-)

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
