Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id DA5756B0032
	for <linux-mm@kvack.org>; Sat, 10 Jan 2015 08:49:12 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id a1so12452942wgh.9
        for <linux-mm@kvack.org>; Sat, 10 Jan 2015 05:49:12 -0800 (PST)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com. [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id hm5si25154308wjb.117.2015.01.10.05.49.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 10 Jan 2015 05:49:11 -0800 (PST)
Received: by mail-wi0-f177.google.com with SMTP id l15so7252648wiw.4
        for <linux-mm@kvack.org>; Sat, 10 Jan 2015 05:49:11 -0800 (PST)
Message-ID: <54B12DD3.5020605@gmail.com>
Date: Sat, 10 Jan 2015 14:49:07 +0100
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86, mpx: Ensure unused arguments of prctl() MPX requests
 are 0
References: <54AE5BE8.1050701@gmail.com> <87r3v350io.fsf@tassilo.jf.intel.com> <CAKgNAki3Fh8N=jyPHxxFpicjyJ=0kA75SJ65QjYzPmWnvy4nsw@mail.gmail.com> <54B01F41.10001@intel.com>
In-Reply-To: <54B01F41.10001@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>
Cc: mtk.manpages@gmail.com, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Qiaowei Ren <qiaowei.ren@intel.com>, lkml <linux-kernel@vger.kernel.org>

On 01/09/2015 07:34 PM, Dave Hansen wrote:
> On 01/09/2015 10:25 AM, Michael Kerrisk (man-pages) wrote:
>> On 9 January 2015 at 18:25, Andi Kleen <andi@firstfloor.org> wrote:
>>> "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com> writes:
>>>> From: Michael Kerrisk <mtk.manpages@gmail.com>
>>>>
>>>> commit fe8c7f5cbf91124987106faa3bdf0c8b955c4cf7 added two new prctl()
>>>> operations, PR_MPX_ENABLE_MANAGEMENT and PR_MPX_DISABLE_MANAGEMENT.
>>>> However, no checks were included to ensure that unused arguments
>>>> are zero, as is done in many existing prctl()s and as should be
>>>> done for all new prctl()s. This patch adds the required checks.
>>>
>>> This will break the existing gcc run time, which doesn't zero these
>>> arguments.
>>
>> I'm a little lost here. Weren't these flags new in the
>> as-yet-unreleased 3.19? How does gcc run-time depends on them already?
> 
> These prctl()s have been around in some form or another for a few months
> since the patches had not yet been merged in to the kernel.  There is
> support for them in a set of (yet unmerged) gcc patches, as well as some
> tests which are only internal to Intel.
> 
> This change will, indeed, break those internal tests as well as the gcc
> patches.  As far as I know, the code is not in production anywhere and
> can be changed.  The prctl() numbers have changed while the patches were
> out of tree and it's a somewhat painful process each time it changes.
> It's not impossible, just painful.

So, sounds like thinks can be fixed (with mild inconvenience), and they
should be fixed before 3.19 is actually released.

Cheers,

Michael



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
