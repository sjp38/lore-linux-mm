Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8027D6B0032
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 13:34:43 -0500 (EST)
Received: by mail-qc0-f177.google.com with SMTP id x3so10361238qcv.8
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 10:34:43 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id m8si13092679qay.103.2015.01.09.10.34.41
        for <linux-mm@kvack.org>;
        Fri, 09 Jan 2015 10:34:42 -0800 (PST)
Message-ID: <54B01F41.10001@intel.com>
Date: Fri, 09 Jan 2015 10:34:41 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86, mpx: Ensure unused arguments of prctl() MPX requests
 are 0
References: <54AE5BE8.1050701@gmail.com> <87r3v350io.fsf@tassilo.jf.intel.com> <CAKgNAki3Fh8N=jyPHxxFpicjyJ=0kA75SJ65QjYzPmWnvy4nsw@mail.gmail.com>
In-Reply-To: <CAKgNAki3Fh8N=jyPHxxFpicjyJ=0kA75SJ65QjYzPmWnvy4nsw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com, Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Qiaowei Ren <qiaowei.ren@intel.com>, lkml <linux-kernel@vger.kernel.org>

On 01/09/2015 10:25 AM, Michael Kerrisk (man-pages) wrote:
> On 9 January 2015 at 18:25, Andi Kleen <andi@firstfloor.org> wrote:
>> "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com> writes:
>>> From: Michael Kerrisk <mtk.manpages@gmail.com>
>>>
>>> commit fe8c7f5cbf91124987106faa3bdf0c8b955c4cf7 added two new prctl()
>>> operations, PR_MPX_ENABLE_MANAGEMENT and PR_MPX_DISABLE_MANAGEMENT.
>>> However, no checks were included to ensure that unused arguments
>>> are zero, as is done in many existing prctl()s and as should be
>>> done for all new prctl()s. This patch adds the required checks.
>>
>> This will break the existing gcc run time, which doesn't zero these
>> arguments.
> 
> I'm a little lost here. Weren't these flags new in the
> as-yet-unreleased 3.19? How does gcc run-time depends on them already?

These prctl()s have been around in some form or another for a few months
since the patches had not yet been merged in to the kernel.  There is
support for them in a set of (yet unmerged) gcc patches, as well as some
tests which are only internal to Intel.

This change will, indeed, break those internal tests as well as the gcc
patches.  As far as I know, the code is not in production anywhere and
can be changed.  The prctl() numbers have changed while the patches were
out of tree and it's a somewhat painful process each time it changes.
It's not impossible, just painful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
