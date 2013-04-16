Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 51F8D6B0006
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 09:07:34 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Tue, 16 Apr 2013 18:34:09 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 9A6341258085
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 18:38:58 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3GD7OkZ50921494
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 18:37:25 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3GD7Rx8021765
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 23:07:28 +1000
Message-ID: <516D4D08.9020602@linux.vnet.ibm.com>
Date: Tue, 16 Apr 2013 21:07:20 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: mmu_notifier: re-fix freed page still mapped in secondary
 MMU
References: <516CF235.4060103@linux.vnet.ibm.com> <20130416093131.GJ3658@sgi.com> <516D275C.8040406@linux.vnet.ibm.com> <20130416112553.GM3658@sgi.com> <20130416114322.GN3658@sgi.com>
In-Reply-To: <20130416114322.GN3658@sgi.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Gleb Natapov <gleb@redhat.com>, Avi Kivity <avi.kivity@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, KVM <kvm@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On 04/16/2013 07:43 PM, Robin Holt wrote:
> Argh.  Taking a step back helped clear my head.
> 
> For the -stable releases, I agree we should just go with your
> revert-plus-hlist_del_init_rcu patch.  I will give it a test
> when I am in the office.

Okay. Wait for your test report. Thank you in advance.

> 
> For the v3.10 release, we should work on making this more
> correct and completely documented.

Better document is always welcomed.

Double call ->release is not bad, like i mentioned it in the changelog:

it is really rare (e.g, can not happen on kvm since mmu-notify is unregistered
after exit_mmap()) and the later call of multiple ->release should be
fast since all the pages have already been released by the first call.

But, of course, it's great if you have a _light_ way to avoid this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
