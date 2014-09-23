Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 35AF96B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 17:54:10 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id v10so6013859pde.20
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 14:54:09 -0700 (PDT)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id x13si23051623pas.83.2014.09.23.14.54.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 14:54:09 -0700 (PDT)
Received: by mail-pd0-f176.google.com with SMTP id z10so5866326pdj.35
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 14:54:01 -0700 (PDT)
Date: Tue, 23 Sep 2014 14:53:56 -0700
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: mmotm 2014-09-22-16-57 uploaded
Message-ID: <20140923215356.GA15481@roeck-us.net>
References: <5420b8b0.9HdYLyyuTikszzH8%akpm@linux-foundation.org>
 <20140923190222.GA4662@roeck-us.net>
 <5421D8B1.1030504@infradead.org>
 <20140923205707.GA14428@roeck-us.net>
 <5421E7E1.80203@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5421E7E1.80203@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, David Miller <davem@davemloft.net>

On Tue, Sep 23, 2014 at 02:36:33PM -0700, Randy Dunlap wrote:
> On 09/23/14 13:57, Guenter Roeck wrote:
> > On Tue, Sep 23, 2014 at 01:31:45PM -0700, Randy Dunlap wrote:
> >> On 09/23/14 12:02, Guenter Roeck wrote:
> >>> On Mon, Sep 22, 2014 at 05:02:56PM -0700, akpm@linux-foundation.org wrote:
> >>>> The mm-of-the-moment snapshot 2014-09-22-16-57 has been uploaded to
> >>>>
> >>>>    http://www.ozlabs.org/~akpm/mmotm/
> >>>>
> >>>> mmotm-readme.txt says
> >>>>
> >>>> README for mm-of-the-moment:
> >>>>
> >>>> http://www.ozlabs.org/~akpm/mmotm/
> >>>>
> >>>> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> >>>> more than once a week.
> >>>>
> >>> Sine I started testing this branch, I figure I might as well share the results.
> >>>
> >>> i386:allyesconfig
> >>>
> >>> drivers/built-in.o: In function `_scsih_qcmd':
> >>> mpt2sas_scsih.c:(.text+0xf5327d): undefined reference to `__udivdi3'
> >>> mpt2sas_scsih.c:(.text+0xf532b0): undefined reference to `__umoddi3'
> >>>
> >>> i386:allmodconfig
> >>>
> >>> ERROR: "__udivdi3" [drivers/scsi/mpt2sas/mpt2sas.ko] undefined!
> >>> ERROR: "__umoddi3" [drivers/scsi/mpt2sas/mpt2sas.ko] undefined!
> >>
> >> A patch has been posted for that and I believe that Christoph Hellwig has
> >> merged it.
> >>
> >>> mips:nlm_xlp_defconfig
> >>>
> >>> ERROR: "scsi_is_fc_rport" [drivers/scsi/libfc/libfc.ko] undefined!
> >>> ERROR: "fc_get_event_number" [drivers/scsi/libfc/libfc.ko] undefined!
> >>> ERROR: "skb_trim" [drivers/scsi/libfc/libfc.ko] undefined!
> >>> ERROR: "fc_host_post_event" [drivers/scsi/libfc/libfc.ko] undefined!
> >>>
> >>> [and many more]
> >>
> >> I have posted a patch for these build errors.
> >>
> > mips:nlm_xlp_defconfig builds in next-20140923, but it doesn't configure
> > CONFIG_NET. I don't see a patch which would address that problem.
> > In case I am missing it, can you point me to your patch ?
> 
> I was referring to this one:
> http://marc.info/?l=linux-scsi&m=141117068414761&w=2
> 
> although I think that Dave is also working on a patch that is a little
> different from mine.
> 
His patch is in next-20140923.

> Neither of these patches enables CONFIG_NET.  They just add dependencies.
> 
This means CONFIG_NET is now disabled in at least 31 configurations where
it used to be enabled before (per my count), and there may be additional
impact due to the additional changes of "select X" to "depends on X".

3.18 is going to be interesting.

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
