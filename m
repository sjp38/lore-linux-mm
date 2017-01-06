Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id CBCD66B0268
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 16:16:24 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id j13so37461618iod.6
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 13:16:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q196si56856616ioe.154.2017.01.06.13.16.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 13:16:23 -0800 (PST)
Date: Fri, 6 Jan 2017 16:16:20 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v15 00/16] HMM (Heterogeneous Memory Management) v15
Message-ID: <20170106211620.GC3804@redhat.com>
References: <1483721203-1678-1-git-send-email-jglisse@redhat.com>
 <bfdbca34-8253-8294-400b-5ddf6e48ae37@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <bfdbca34-8253-8294-400b-5ddf6e48ae37@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Ben Skeggs <bskeggs@redhat.com>

On Fri, Jan 06, 2017 at 12:54:41PM -0800, Dave Hansen wrote:
> On 01/06/2017 08:46 AM, Jerome Glisse wrote:
> > I think it is ready for next or at least i would like to know any
> > reasons to not accept this patchset.
> 
> Do you have a real in-tree user for this yet?

Nouvau would be the first one we don't have the kernel space bit yet
to support page fault. We definitly plan to have this working with
nouveau, maybe 4.10 or 4.11.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
