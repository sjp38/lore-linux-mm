From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/11] x86, memblock: Allocate memory near kernel image
 before SRAT parsed.
Date: Tue, 10 Sep 2013 07:58:00 +0800
Message-ID: <27278.8297072568$1378771112@news.gmane.org>
References: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>
 <20130904192215.GG26609@mtj.dyndns.org>
 <52299935.0302450a.26c9.ffffb240SMTPIN_ADDED_BROKEN@mx.google.com>
 <20130906151526.GA22423@mtj.dyndns.org>
 <522db781.22ab440a.41b1.ffffd825SMTPIN_ADDED_BROKEN@mx.google.com>
 <20130909135815.GB25434@htj.dyndns.org>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1VJBLa-0002Ai-4q
	for glkm-linux-mm-2@m.gmane.org; Tue, 10 Sep 2013 01:58:22 +0200
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 2038C6B0032
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 19:58:19 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 10 Sep 2013 20:51:55 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 4423C3578054
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 09:58:12 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r89Nvqot6488398
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 09:58:01 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r89Nw2Ac023119
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 09:58:03 +1000
Content-Disposition: inline
In-Reply-To: <20130909135815.GB25434@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hi Tejun,
On Mon, Sep 09, 2013 at 09:58:15AM -0400, Tejun Heo wrote:
>Hello,
>
>On Mon, Sep 09, 2013 at 07:56:34PM +0800, Wanpeng Li wrote:
>> If allocate from low to high as what this patchset done will occupy the
>> precious memory you mentioned?
>
>Yeah, and that'd be the reason why this behavior is dependent on a
>kernel option.  That said, allocating some megs on top of kernel isn't
>a big deal.  The wretched ISA DMA is mostly gone now and some megs
>isn't gonna hurt 32bit DMAs in any noticeable way.  I wouldn't be too
>surprised if nobody notices after switching the default behavior to
>allocate early mem close to kernel.  Maybe the only case which might
>be impacted is 32bit highmem configs, but they're messed up no matter
>what anyway and even they shouldn't be affected noticeably if large
>mapping is in use.

ISA DMA is still survive for 32bit highmem configs. In my desktop:

c1000000 T _text => 16MB
c1d09000 B _end  => 29MB

This patchset will alloc after 29MB. ;-)

Regards,
Wanpeng Li 

>
>Thanks.
>
>-- 
>tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
