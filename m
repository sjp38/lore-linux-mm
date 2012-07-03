Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 4421F6B005D
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 02:41:12 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Tue, 3 Jul 2012 06:31:44 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q636XDEH45416520
	for <linux-mm@kvack.org>; Tue, 3 Jul 2012 16:33:14 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q636f4Fp000543
	for <linux-mm@kvack.org>; Tue, 3 Jul 2012 16:41:04 +1000
Message-ID: <4FF293FE.2010100@linux.vnet.ibm.com>
Date: Tue, 03 Jul 2012 14:41:02 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: kvm segfaults and bad page state in 3.4.0
References: <20120604114603.GA6988@localhost>
In-Reply-To: <20120604114603.GA6988@localhost>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Fengguang,

I can reproduce this bug in my test case, and have posted
a patch to fix it which can found at:
http://marc.info/?l=linux-mm&m=134129723504527&w=2

Could you please try it?

On 06/04/2012 07:46 PM, Fengguang Wu wrote:
> Hi,
> 
> I'm running lots of kvm instances for doing kernel boot tests.
> Unfortunately the test system itself is not stable enough, I got scary
> errors in both kvm and the host kernel. Like this. 
> 
> [294025.795382] kvm used greatest stack depth: 2896 bytes left
> [310388.622083] kvm[1864]: segfault at c ip 00007f498e9f6a81 sp 00007f4994b9fca0 error 4 in kvm[7f498e960000+33b000]
> [310692.050589] kvm[4332]: segfault at 10 ip 00007fca662620b9 sp 00007fca70472af0 error 6 in kvm[7fca661cc000+33b000]
> [312608.950120] kvm[18931]: segfault at 8 ip 00007f95962a10a5 sp 00007f959d777170 error 4 in kvm[7f959620b000+33b000]
> [312622.941640] kvm[19123]: segfault at 10 ip 00007f406f5580b9 sp 00007f4077d8b350 error 6 in kvm[7f406f4c2000+33b000]
> [313917.860951] kvm[28789]: segfault at c ip 00007f718f4dfa81 sp 00007f7198459520 error 4 in kvm[7f718f449000+33b000]
> [313919.177192] kvm used greatest stack depth: 2864 bytes left
> [314061.390945] kvm used greatest stack depth: 2208 bytes left
> [327479.676068] BUG: Bad page state in process kvm  pfn:59ac9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
