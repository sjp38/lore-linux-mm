Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f170.google.com (mail-yw0-f170.google.com [209.85.161.170])
	by kanga.kvack.org (Postfix) with ESMTP id 63C61828DF
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 17:05:35 -0500 (EST)
Received: by mail-yw0-f170.google.com with SMTP id u200so34752220ywf.0
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 14:05:35 -0800 (PST)
Received: from mail-yw0-x235.google.com (mail-yw0-x235.google.com. [2607:f8b0:4002:c05::235])
        by mx.google.com with ESMTPS id 189si14269623ybu.8.2016.02.08.14.05.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Feb 2016 14:05:34 -0800 (PST)
Received: by mail-yw0-x235.google.com with SMTP id h129so113485797ywb.1
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 14:05:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <x49vb5yvrzv.fsf@segfault.boston.devel.redhat.com>
References: <1454829553-29499-1-git-send-email-ross.zwisler@linux.intel.com>
	<1454829553-29499-3-git-send-email-ross.zwisler@linux.intel.com>
	<CAPcyv4jT=yAb2_yLfMGqV1SdbQwoWQj7joroeJGAJAcjsMY_oQ@mail.gmail.com>
	<20160207215047.GJ31407@dastard>
	<CAPcyv4jNmdm-ATTBaLLLzBT+RXJ0YrxxXLYZ=T7xUgEJ8PaSKw@mail.gmail.com>
	<20160208201808.GK27429@dastard>
	<CAPcyv4iHi17pv_VC=WgEP4_GgN9OvSr8xbw1bvbEFMiQ83GbWw@mail.gmail.com>
	<x49vb5yvrzv.fsf@segfault.boston.devel.redhat.com>
Date: Mon, 8 Feb 2016 14:05:34 -0800
Message-ID: <CAPcyv4iHaFNBRBb4EYPfHX+pB5srJbqrOX7FnDXyDPy92Cnpww@mail.gmail.com>
Subject: Re: [PATCH 2/2] dax: move writeback calls into the filesystems
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, XFS Developers <xfs@oss.sgi.com>

On Mon, Feb 8, 2016 at 12:58 PM, Jeff Moyer <jmoyer@redhat.com> wrote:
> Dan Williams <dan.j.williams@intel.com> writes:
>
>> I agree the mount option needs to die, and I fully grok the reasoning.
>>   What I'm concerned with is that a system using fully-DAX-aware
>> applications is forced to incur the overhead of maintaining *sync
>> semantics, periodic sync(2) in particular,  even if it is not relying
>> on those semantics.
>>
>> However, like I said in my other mail, we can solve that with
>> alternate interfaces to persistent memory if that becomes an issue and
>> not require that "disable *sync" capability to come through DAX.
>
> What do you envision these alternate interfaces looking like?

Well, plan-A was making DAX be explicit opt-in for applications, I
haven't thought too much about plan-B.  I expect it to be driven by
real performance numbers and application use cases once the *sync
compat work completes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
