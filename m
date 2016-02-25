Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id EE5396B0253
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 08:49:36 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id a4so28360474wme.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 05:49:36 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id v125si4182832wme.79.2016.02.25.05.49.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 05:49:33 -0800 (PST)
Date: Thu, 25 Feb 2016 14:49:33 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [LSF/MM ATTEND] HMM (heterogeneous memory manager) and GPU
Message-ID: <20160225134933.GD22747@8bytes.org>
References: <20160128175536.GA20797@gmail.com>
 <1454460057.4788.117.camel@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1454460057.4788.117.camel@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Jerome Glisse <j.glisse@gmail.com>, lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hey,

On Wed, Feb 03, 2016 at 12:40:57AM +0000, David Woodhouse wrote:
> There are a few related issues here around Shared Virtual Memory, and
> lifetime management of the associated MM, and the proposal discussed at
> the Kernel Summit for "off-CPU tasks".
> 
> I've hit a situation with the Intel SVM code in 4.4 where the device
> driver binds a PASID, and also has mmap() functionality on the same
> file descriptor that the PASID is associated with.
> 
> So on process exit, the MM doesn't die because the PASID binding still
> exists. The VMA of the mmap doesn't die because the MM still exists. So
> the underlying file remains open because the VMA still exists. And the
> PASID binding thus doesn't die because the file is still open.
> 
> I've posted a patchA1 which moves us closer to the amd_iommu_v2 model,
> although I'm still *strongly* resisting the temptation to call out into
> device driver code from the mmu_notifier's release callback.
> 
> I would like to attend LSF/MM this year so we can continue to work on
> those issues a?? now that we actually have some hardware in the field and
> a better idea of how we can build a unified access model for SVM across
> the different IOMMU types.

That sounds very interesting and I'd like to participate in this
discussion. Unfortunatly I can't make it to the mm-sumit this year, so I
didn't even apply for an invitation.

But if this gets discussed there I am interested in the outcome. I still
have a prototype for the off-cpu task concept on my list of thing to
implement. The problem is that I can't really test any changes I make
because I don't have SVM hardware and on the AMD side the user-space
part needed for testing only runs on Ubuntu with some AMD provided
kernel :(


	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
