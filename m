Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 210BB6B005D
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 02:48:28 -0400 (EDT)
Date: Tue, 3 Jul 2012 14:48:22 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: kvm segfaults and bad page state in 3.4.0
Message-ID: <20120703064822.GA17367@localhost>
References: <20120604114603.GA6988@localhost>
 <4FF293FE.2010100@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FF293FE.2010100@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Guangrong,

On Tue, Jul 03, 2012 at 02:41:02PM +0800, Xiao Guangrong wrote:
> Hi Fengguang,
> 
> I can reproduce this bug in my test case, and have posted
> a patch to fix it which can found at:
> http://marc.info/?l=linux-mm&m=134129723504527&w=2
> 
> Could you please try it?

Thank you very much! I'm glad to try it out in my compile servers.
Note that I've not encountered the bug since then (seems not very
reproducible). So the feedback would be kind of "the patch works well"
rather than confirming that it fixed the bug for me. Sorry for that.

Thanks,
Fengguang

> On 06/04/2012 07:46 PM, Fengguang Wu wrote:
> > Hi,
> > 
> > I'm running lots of kvm instances for doing kernel boot tests.
> > Unfortunately the test system itself is not stable enough, I got scary
> > errors in both kvm and the host kernel. Like this. 
> > 
> > [294025.795382] kvm used greatest stack depth: 2896 bytes left
> > [310388.622083] kvm[1864]: segfault at c ip 00007f498e9f6a81 sp 00007f4994b9fca0 error 4 in kvm[7f498e960000+33b000]
> > [310692.050589] kvm[4332]: segfault at 10 ip 00007fca662620b9 sp 00007fca70472af0 error 6 in kvm[7fca661cc000+33b000]
> > [312608.950120] kvm[18931]: segfault at 8 ip 00007f95962a10a5 sp 00007f959d777170 error 4 in kvm[7f959620b000+33b000]
> > [312622.941640] kvm[19123]: segfault at 10 ip 00007f406f5580b9 sp 00007f4077d8b350 error 6 in kvm[7f406f4c2000+33b000]
> > [313917.860951] kvm[28789]: segfault at c ip 00007f718f4dfa81 sp 00007f7198459520 error 4 in kvm[7f718f449000+33b000]
> > [313919.177192] kvm used greatest stack depth: 2864 bytes left
> > [314061.390945] kvm used greatest stack depth: 2208 bytes left
> > [327479.676068] BUG: Bad page state in process kvm  pfn:59ac9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
