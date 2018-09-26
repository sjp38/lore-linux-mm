Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC0C8E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 18:36:19 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id v9-v6so619302pff.4
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 15:36:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l15-v6si216878pgh.593.2018.09.26.15.36.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 15:36:18 -0700 (PDT)
Date: Wed, 26 Sep 2018 15:36:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 2/4] mm: Provide kernel parameter to allow disabling
 page init poisoning
Message-Id: <20180926153615.90661e27d0713a02651b2282@linux-foundation.org>
In-Reply-To: <f5648747-642f-763e-80b9-24fb203c85e9@intel.com>
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
	<20180925201921.3576.84239.stgit@localhost.localdomain>
	<20180926073831.GC6278@dhcp22.suse.cz>
	<f5648747-642f-763e-80b9-24fb203c85e9@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, jglisse@redhat.com, rppt@linux.vnet.ibm.com, dan.j.williams@intel.com, logang@deltatee.com, mingo@kernel.org, kirill.shutemov@linux.intel.com

On Wed, 26 Sep 2018 08:36:47 -0700 Dave Hansen <dave.hansen@intel.com> wrote:

> On 09/26/2018 12:38 AM, Michal Hocko wrote:
> > Why cannot you simply go with [no]vm_page_poison[=on/off]?
> 
> I was trying to look to the future a bit, if we end up with five or six
> more other options we want to allow folks to enable/disable.  I don't
> want to end up in a situation where we have a bunch of different knobs
> to turn all this stuff off at runtime.
> 
> I'd really like to have one stop shopping so that folks who have a
> system that's behaving well and don't need any debugging can get some of
> their performance back.
> 
> But, the *primary* thing we want here is a nice, quick way to turn as
> much debugging off as we can.  A nice-to-have is a future-proof,
> slub-style option that will centralize things.

Yup.  DEBUG_VM just covers too much stuff nowadays.  A general way to
make these thing more fine-grained and without requiring a rebuild
would be great.

And I expect that quite a few of the debug features could be
enabled/disabled after bootup as well, so a /proc knob is probably in
our future.  Any infrastructure which is added to support a new
kernel-command-line option should be designed with that in mind.
