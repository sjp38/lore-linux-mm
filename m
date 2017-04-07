Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0F2CB6B0390
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 14:28:00 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id n80so23109370qke.6
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 11:28:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w64si2285075qtd.101.2017.04.07.11.27.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Apr 2017 11:27:59 -0700 (PDT)
Date: Fri, 7 Apr 2017 14:27:52 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 01/16] mm/memory/hotplug: add memory type parameter to
 arch_add/remove_memory
Message-ID: <20170407182752.GA17852@redhat.com>
References: <20170405204026.3940-2-jglisse@redhat.com>
 <20170407121349.GB16392@dhcp22.suse.cz>
 <20170407143246.GA15098@redhat.com>
 <20170407144504.GG16413@dhcp22.suse.cz>
 <20170407145740.GA15335@redhat.com>
 <20170407151105.GH16413@dhcp22.suse.cz>
 <20170407160959.GA15945@redhat.com>
 <20170407163737.GI16413@dhcp22.suse.cz>
 <20170407171055.GA16527@redhat.com>
 <20170407175912.GL16413@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170407175912.GL16413@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Russell King <linux@armlinux.org.uk>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

On Fri, Apr 07, 2017 at 07:59:12PM +0200, Michal Hocko wrote:
> On Fri 07-04-17 13:10:59, Jerome Glisse wrote:
> > On Fri, Apr 07, 2017 at 06:37:37PM +0200, Michal Hocko wrote:
> > > On Fri 07-04-17 12:10:00, Jerome Glisse wrote:
> [...]
> > > > No guaranteed so yes i somewhat care about max_pfn, i do not care about
> > > > any of its existing user last time i check but it might matter for some
> > > > new user.
> > > 
> > > OK, then we can add add_pages() which would do __add_pages by default
> > > (#ifndef ARCH_HAS_ADD_PAGES) and x86 would override it do also call
> > > update_end_of_memory_vars. This sounds easier to me than updating all
> > > the archs and add something that most of them do not really care about.
> > > 
> > > But I will not insist. If you think that your approach is better I will
> > > not object.
> > 
> > Something like attached patch ?
> 
> No I meant something like the diff below but maybe even that is too
> excessive.

No looks good to me at least. But i am no authority there.


> > > Btw. is your series reviewed and ready to be applied to the mm tree? I
> > > planed to post mine on Monday so I would like to know how do we
> > > coordinate. I rebase on topo of yours or vice versa.
> > 
> > Well v18 core patches were review by Mel, i did include all of his comment
> > in v19 (i don't think i did miss any). I think Dan still want to look at
> > patch 1 and 3 for ZONE_DEVICE.
> > 
> > But i always welcome more review. I know Anshuman replied to this patch
> > to improve a comments. Balbir had issue on powerpc because iomem_resource.end
> > isn't clamped to MAX_PHYSMEM_BITS But that is all review i got so far on v19.
> > 
> > I don't mind rebasing on top of your patchset. What ever is easier for
> > Andrew i guess.
> 
> Well, considering that my patchset is changing the behavior of the core
> of the memory hotplug I would prefer if it could go first and add new
> user on top. But I realize that you are maintaining your series for a
> _long_ time so I would completely understand if you wouldn't be
> impressed by another rebase...
> 
> If you are OK with rebasing and I will help you with that as much as I
> can I would be really grateful.


I don't mind rebasing on top of your patchset after you post. This is minor
change for me.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
