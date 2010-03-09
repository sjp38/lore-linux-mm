Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5963D6B00CE
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 16:22:05 -0500 (EST)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.1/8.13.1) with ESMTP id o29LM0uS032668
	for <linux-mm@kvack.org>; Tue, 9 Mar 2010 21:22:00 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o29LLxMl1593498
	for <linux-mm@kvack.org>; Tue, 9 Mar 2010 22:21:59 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o29LLxCE016146
	for <linux-mm@kvack.org>; Tue, 9 Mar 2010 22:21:59 +0100
Date: Tue, 9 Mar 2010 22:22:11 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH 2/2] memory hotplug/s390: set phys_device
Message-ID: <20100309212211.GA2288@osiris.boeblingen.de.ibm.com>
References: <20100309172052.GC2360@osiris.boeblingen.de.ibm.com>
 <20100309123748.3015e10a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100309123748.3015e10a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 09, 2010 at 12:37:48PM -0800, Andrew Morton wrote:
> On Tue, 9 Mar 2010 18:20:52 +0100
> Heiko Carstens <heiko.carstens@de.ibm.com> wrote:
> 
> > From: Heiko Carstens <heiko.carstens@de.ibm.com>
> > 
> > Implement arch specific arch_get_memory_phys_device function and initialize
> > phys_device for each memory section. That way we finally can tell which
> > piece of memory belongs to which physical device.
> > 
> > --- a/drivers/s390/char/sclp_cmd.c
> > +++ b/drivers/s390/char/sclp_cmd.c
> > @@ -704,6 +704,13 @@ int sclp_chp_deconfigure(struct chp_id c
> >  	return do_chp_configure(SCLP_CMDW_DECONFIGURE_CHPATH | chpid.id << 8);
> >  }
> >  
> > +int arch_get_memory_phys_device(unsigned long start_pfn)
> > +{
> > +	if (!rzm)
> > +		return 0;
> > +	return PFN_PHYS(start_pfn) / rzm;
> > +}
> > +
> >  struct chp_info_sccb {
> >  	struct sccb_header header;
> >  	u8 recognized[SCLP_CHP_INFO_MASK_SIZE];
> 
> What is the utility of this patch?  It makes s390's
> /sys/devices/system/memory/memoryX/phys_device display the correct
> thing?

Yes, exactly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
