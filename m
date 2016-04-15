Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D2CE66B025E
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 14:56:21 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id fg3so41819030obb.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 11:56:21 -0700 (PDT)
Received: from mail-oi0-x22a.google.com (mail-oi0-x22a.google.com. [2607:f8b0:4003:c06::22a])
        by mx.google.com with ESMTPS id l20si3925552otd.11.2016.04.15.11.56.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 11:56:21 -0700 (PDT)
Received: by mail-oi0-x22a.google.com with SMTP id p188so132824834oih.2
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 11:56:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <x494mb2ivcl.fsf@segfault.boston.devel.redhat.com>
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
	<1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
	<x49twj26edj.fsf@segfault.boston.devel.redhat.com>
	<1460739288.3012.3.camel@intel.com>
	<x49potq6bm2.fsf@segfault.boston.devel.redhat.com>
	<1460741821.3012.11.camel@intel.com>
	<CAPcyv4hemNM4uQYCPBXyH+DWTOLvyBNBeMYstKbPdad_Cw48HQ@mail.gmail.com>
	<x49lh4e6928.fsf@segfault.boston.devel.redhat.com>
	<CAPcyv4hRQj2ZsFj7Xa_=OwcHrzP9_5yUpt3LQ+bPH4PcLe7UCQ@mail.gmail.com>
	<x494mb2ivcl.fsf@segfault.boston.devel.redhat.com>
Date: Fri, 15 Apr 2016 11:56:20 -0700
Message-ID: <CAPcyv4jcPDDcru1ySJLY7SzDQQWFXbfHm493N0twa1vHBEc6aQ@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: "Verma, Vishal L" <vishal.l.verma@intel.com>, "hch@infradead.org" <hch@infradead.org>, "jack@suse.cz" <jack@suse.cz>, "axboe@fb.com" <axboe@fb.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "david@fromorbit.com" <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>

On Fri, Apr 15, 2016 at 11:24 AM, Jeff Moyer <jmoyer@redhat.com> wrote:
>> Moreover, we're going to do the full badblocks lookup anyway when we
>> call ->direct_access().  If we had that information earlier we can
>> avoid this fallback dance.
>
> None of the proposed approaches looks clean to me.  I'll go along with
> whatever you guys think is best.  I am in favor of wrapping up all that
> duplicated code, though.

Christoph originally pushed for open coding this fallback decision
per-filesystem.  I agree with you on the "none the above" options are
clean.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
