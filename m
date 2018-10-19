Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9B26B0003
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 12:33:56 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id t3-v6so25058703pgp.0
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 09:33:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m6-v6sor11652969plt.65.2018.10.19.09.33.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Oct 2018 09:33:54 -0700 (PDT)
Date: Fri, 19 Oct 2018 12:33:48 -0400
From: Barret Rhoden <brho@google.com>
Subject: Re: [PATCH V5 4/4] kvm: add a check if pfn is from NVDIMM pmem.
Message-ID: <20181019123348.04ee7dd8@gnomeregan.cam.corp.google.com>
In-Reply-To: <159bb198-a4a1-0fee-bf57-24c3c28788bd@redhat.com>
References: <cover.1536342881.git.yi.z.zhang@linux.intel.com>
	<4e8c2e0facd46cfaf4ab79e19c9115958ab6f218.1536342881.git.yi.z.zhang@linux.intel.com>
	<CAPcyv4ifg2BZMTNfu6mg0xxtPWs3BVgkfEj51v1CQ6jp2S70fw@mail.gmail.com>
	<fefbd66e-623d-b6a5-7202-5309dd4f5b32@redhat.com>
	<20180920224953.GA53363@tiger-server>
	<CAPcyv4g6OS=_uSjJenn5WVmpx7zCRCbzJaBr_m0Bq=qyEyVagg@mail.gmail.com>
	<20180921224739.GA33892@tiger-server>
	<c8ad8ed7-ca8c-4dd7-819b-8d9c856fbe04@redhat.com>
	<CAPcyv4j9K-wkq8oK-8_twWViKhyGSHD7cOE5UoRN-09xKXPq7A@mail.gmail.com>
	<159bb198-a4a1-0fee-bf57-24c3c28788bd@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, Dan Williams <dan.j.williams@intel.com>
Cc: KVM list <kvm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Paolo Bonzini <pbonzini@redhat.com>, Dave Jiang <dave.jiang@intel.com>, "Zhang, Yu C" <yu.c.zhang@intel.com>, Pankaj Gupta <pagupta@redhat.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, rkrcmar@redhat.com, =?UTF-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, "Zhang, Yi Z" <yi.z.zhang@intel.com>

On 2018-09-21 at 21:29 David Hildenbrand <david@redhat.com> wrote:
> On 21/09/2018 20:17, Dan Williams wrote:
> > On Fri, Sep 21, 2018 at 7:24 AM David Hildenbrand <david@redhat.com> wrote:
> > [..]  
> >>> Remove the PageReserved flag sounds more reasonable.
> >>> And Could we still have a flag to identify it is a device private memory, or
> >>> where these pages coming from?  
> >>
> >> We could use a page type for that or what you proposed. (as I said, we
> >> might have to change hibernation code to skip the pages once we drop the
> >> reserved flag).  
> > 
> > I think it would be reasonable to reject all ZONE_DEVICE pages in
> > saveable_page().
> >   
> 
> Indeed, that sounds like the easiest solution - guess that answer was
> too easy for me to figure out :) .
> 

Just to follow-up, is the plan to clear PageReserved for nvdimm pages
instead of the approach taken in this patch set?  Or should we special
case nvdimm/dax pages in kvm_is_reserved_pfn()?

Thanks,

Barret
