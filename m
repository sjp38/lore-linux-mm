Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0FC6B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 15:14:37 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id q1so90241890qkb.3
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 12:14:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g63si15271420qkg.528.2017.07.26.12.14.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 12:14:36 -0700 (PDT)
Date: Wed, 26 Jul 2017 15:14:32 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
Message-ID: <20170726191432.GC21717@redhat.com>
References: <20170711182922.GC5347@redhat.com>
 <7a4478cb-7eb6-2546-e707-1b0f18e3acd4@nvidia.com>
 <20170711184919.GD5347@redhat.com>
 <84d83148-41a3-d0e8-be80-56187a8e8ccc@nvidia.com>
 <20170713201620.GB1979@redhat.com>
 <ca12b033-8ec5-84b0-c2aa-ea829e1194fa@nvidia.com>
 <20170715005554.GA12694@redhat.com>
 <cfba9bfb-5178-bcae-0fa9-ef66e2a871d5@nvidia.com>
 <20170721013303.GA25991@redhat.com>
 <5602b0e5-0051-f726-420e-7013446d3f42@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5602b0e5-0051-f726-420e-7013446d3f42@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Tue, Jul 25, 2017 at 03:45:14PM -0700, Evgeny Baskakov wrote:
> On 7/20/17 6:33 PM, Jerome Glisse wrote:
> 
> > So i pushed an updated hmm-next branch it should have all fixes so far, including
> > something that should fix this issue. I still want to go over all emails again
> > to make sure i am not forgetting anything.
> > 
> > Cheers,
> > Jerome
> 
> Hi Jerome,
> 
> Thanks for updating the documentation for hmm_devmem_ops.
> 
> I have an inquiry about the "fault" callback, though. The documentation says
> "Returns: 0 on success", but can the driver set any VM_FAULT_* flags? For
> instance, the driver might want to set the VM_FAULT_MAJOR flag to indicate
> that a heavy-weight page migration has happened on the page fault.
> 
> If that is possible, can you please update the documentation and list the
> flags that are permitted in the callback's return value?

Yes you can.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
