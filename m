Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7166B77A6
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 04:31:53 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id w42-v6so3268788eda.23
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 01:31:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f5-v6si3725677eda.356.2018.09.06.01.31.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 01:31:52 -0700 (PDT)
Date: Thu, 6 Sep 2018 10:31:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 04/29] mm: remove bootmem allocator implementation.
Message-ID: <20180906083149.GZ14951@dhcp22.suse.cz>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-5-git-send-email-rppt@linux.vnet.ibm.com>
 <20180906073023.GO14951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180906073023.GO14951@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 06-09-18 09:30:23, Michal Hocko wrote:
> Is there any reason to keep
> 
> ifdef CONFIG_NO_BOOTMEM
> 	obj-y		+= nobootmem.o
> else
> 	obj-y		+= bootmem.o
> endif
> 
> behind?

I can see you have done so in an earlier patch. I have missed that.
-- 
Michal Hocko
SUSE Labs
