Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 44E1A6B0038
	for <linux-mm@kvack.org>; Sat, 18 Mar 2017 08:45:48 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g2so189941218pge.7
        for <linux-mm@kvack.org>; Sat, 18 Mar 2017 05:45:48 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id n8si11522305pgd.294.2017.03.18.05.45.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 18 Mar 2017 05:45:47 -0700 (PDT)
Date: Sat, 18 Mar 2017 20:48:55 +0800
From: Philip Li <philip.li@intel.com>
Subject: Re: [kbuild-all] [mmotm:master 119/211] mm/migrate.c:2184:5: note:
 in expansion of macro 'MIGRATE_PFN_DEVICE'
Message-ID: <20170318124855.GA16796@intel.com>
References: <201703170923.JOG5lvVO%fengguang.wu@intel.com>
 <20170316204135.da11fb9a50d22c264404a30e@linux-foundation.org>
 <20170317040608.islf67cjbe25rjnx@wfg-t540p.sh.intel.com>
 <503478426.8747709.1489790882925.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <503478426.8747709.1489790882925.JavaMail.zimbra@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>

On Fri, Mar 17, 2017 at 06:48:02PM -0400, Jerome Glisse wrote:
> > Hi Andrew,
> > 
> > On Thu, Mar 16, 2017 at 08:41:35PM -0700, Andrew Morton wrote:
> > >On Fri, 17 Mar 2017 09:46:30 +0800 kbuild test robot
> > ><fengguang.wu@intel.com> wrote:
> > >
> > >> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> > >> head:   8276ddb3c638602509386f1a05f75326dbf5ce09
> > >> commit: a6d9a210db7db40e98f7502608c6f1413c44b9b9 [119/211] mm/hmm/migrate:
> > >> support un-addressable ZONE_DEVICE page in migration
> > >
> > >heh, I think the HMM patchset just scored the world record number of
> > >build errors.  Thanks for doing this.
> > >
> > >But why didn't we find out earlier than v18?  Don't you scoop patchsets
> > >off the mailing list *before* someone merges them into an upstream
> > >tree?
> > 
> > Yes we test LKML patches, however not all patches can be successfully
> > applied, so cannot be tested at all.
> 
> When patchset fails to apply can the poster get an email so he knows that
> his patchset isn't gonna be build tested.
Hi Jerome, thanks for feedback, sure, we will add this to next quarter's plan
to let author know if his patchset is not tested, also will allow opt in if
some developer wants to have build success notification as well.

> 
> Regards,
> Jerome Glisse
> _______________________________________________
> kbuild-all mailing list
> kbuild-all@lists.01.org
> https://lists.01.org/mailman/listinfo/kbuild-all

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
