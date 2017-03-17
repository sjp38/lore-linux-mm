Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C46AE6B038A
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 11:52:43 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id n37so66096769qtb.7
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 08:52:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k67si6742020qkb.55.2017.03.17.08.52.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 08:52:42 -0700 (PDT)
Date: Fri, 17 Mar 2017 11:52:37 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 00/16] HMM (Heterogeneous Memory Management) v18
Message-ID: <20170317155236.GA7582@redhat.com>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
 <20170316134321.c5cf727c21abf89b7e6708a2@linux-foundation.org>
 <20170316234950.GA5725@redhat.com>
 <a0e1af7b-d8a6-2277-b659-66608cc61ef5@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a0e1af7b-d8a6-2277-b659-66608cc61ef5@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <liubo95@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>

On Fri, Mar 17, 2017 at 04:39:28PM +0800, Bob Liu wrote:
> On 2017/3/17 7:49, Jerome Glisse wrote:
> > On Thu, Mar 16, 2017 at 01:43:21PM -0700, Andrew Morton wrote:
> >> On Thu, 16 Mar 2017 12:05:19 -0400 J__r__me Glisse <jglisse@redhat.com> wrote:
> >>
> >>> Cliff note:
> >>
> >> "Cliff's notes" isn't appropriate for a large feature such as this. 
> >> Where's the long-form description?  One which permits readers to fully
> >> understand the requirements, design, alternative designs, the
> >> implementation, the interface(s), etc?
> >>
> >> Have you ever spoken about HMM at a conference?  If so, the supporting
> >> presentation documents might help here.  That's the level of detail
> >> which should be presented here.
> > 
> > Longer description of patchset rational, motivation and design choices
> > were given in the first few posting of the patchset to which i included
> > a link in my cover letter. Also given that i presented that for last 3
> > or 4 years to mm summit and kernel summit i thought that by now peoples
> > were familiar about the topic and wanted to spare them the long version.
> > My bad.
> > 
> > I attach a patch that is a first stab at a Documentation/hmm.txt that
> > explain the motivation and rational behind HMM. I can probably add a
> > section about how to use HMM from device driver point of view.
> > 
> 
> And a simple example program/pseudo-code make use of the device memory 
> would also very useful for person don't have GPU programming experience :)

Like i said there is no userspace API to this. Right now it is under
driver control what and when to migrate. So this is specific to each
driver and without a driver which use this feature nothing happen. 

Each driver will expose its own API that probably won't be expose to
the end user but to the user space driver (OpenCL, Cuda, C++, OpenMP,
...). We are not sure what kind of API we will expose in the nouveau
driver this still need to be discuss. Same for the AMD driver.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
