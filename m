Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id F349A6B0038
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 13:45:15 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id o3so84984232ita.3
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 10:45:15 -0700 (PDT)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id 8si5092527otm.126.2016.09.15.10.44.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 10:44:54 -0700 (PDT)
Received: by mail-oi0-x230.google.com with SMTP id w11so80464116oia.2
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 10:44:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160915170942.GJ9314@birch.djwong.org>
References: <147392246509.9873.17750323049785100997.stgit@dwillia2-desk3.amr.corp.intel.com>
 <147392247875.9873.4205533916442000884.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20160915082615.GA9772@lst.de> <CAPcyv4jTw3cXpmmJRh7t16Xy2uYofDe+fJ+X_jnz+Q=o0uGneg@mail.gmail.com>
 <20160915170942.GJ9314@birch.djwong.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 15 Sep 2016 10:44:53 -0700
Message-ID: <CAPcyv4h4f468Dt3Uv2YJO18TD2rN=s+xJRWK4QvOvxANSkdesA@mail.gmail.com>
Subject: Re: [PATCH v2 2/3] mm, dax: add VM_DAX flag for DAX VMAs
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Nicholas Piggin <npiggin@gmail.com>, XFS Developers <xfs@oss.sgi.com>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Thu, Sep 15, 2016 at 10:09 AM, Darrick J. Wong
<darrick.wong@oracle.com> wrote:
> On Thu, Sep 15, 2016 at 10:01:03AM -0700, Dan Williams wrote:
>> On Thu, Sep 15, 2016 at 1:26 AM, Christoph Hellwig <hch@lst.de> wrote:
>> > On Wed, Sep 14, 2016 at 11:54:38PM -0700, Dan Williams wrote:
>> >> The DAX property, page cache bypass, of a VMA is only detectable via the
>> >> vma_is_dax() helper to check the S_DAX inode flag.  However, this is
>> >> only available internal to the kernel and is a property that userspace
>> >> applications would like to interrogate.
>> >
>> > They have absolutely no business knowing such an implementation detail.
>>
>> Hasn't that train already left the station with FS_XFLAG_DAX?
>
> Seeing as FS_IOC_FSGETXATTR is a "generic" ioctl now, why not just
> implement it for all the DAX fses and block devices?  Aside from xflags,
> the other fields are probably all zero for non-xfs (aside from project
> quota id I guess).
>
> (Yeah, sort of awkward, I know...)

It would solve the problem at hand, I'll take a look.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
