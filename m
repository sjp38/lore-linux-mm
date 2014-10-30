Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 196AF90008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 05:02:17 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id h11so6737899wiw.0
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 02:02:16 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id na16si9729602wic.20.2014.10.30.02.02.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Oct 2014 02:02:15 -0700 (PDT)
Received: by mail-wi0-f182.google.com with SMTP id d1so6714837wiv.15
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 02:02:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1414619976.2542.1.camel@perches.com>
References: <54515a25.46WrYSce5BExT3V4%akpm@linux-foundation.org>
	<alpine.DEB.2.11.1410292233340.5308@nanos>
	<1414619976.2542.1.camel@perches.com>
Date: Thu, 30 Oct 2014 10:02:15 +0100
Message-ID: <CAFLxGvwGRz8Z2=eD53VjVgUf5zdM3KCyLcUZN1g_Po2D2xQ4DA@mail.gmail.com>
Subject: Re: mmotm 2014-10-29-14-19 uploaded
From: Richard Weinberger <richard.weinberger@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, mm-commits@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-next@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, Michal Hocko <mhocko@suse.cz>

On Wed, Oct 29, 2014 at 10:59 PM, Joe Perches <joe@perches.com> wrote:
> On Wed, 2014-10-29 at 22:37 +0100, Thomas Gleixner wrote:
>> On Wed, 29 Oct 2014, akpm@linux-foundation.org wrote:
>> > This mmotm tree contains the following patches against 3.18-rc2:
>> > (patches marked "*" will be included in linux-next)
>> >
>> > * kernel-posix-timersc-code-clean-up.patch
>>
>> Can you please drop this pointless churn? We really can replace all
>> that stuff with a shell script and let it run over the tree every now
>> and then.
>
> Should any automated code reformatting really be done
> by an unsupervised or unreviewed shell script?

As many users of "checkpatch.pl -f" behave anyway like
unsupervised/unreviewed shell scripts
it would not matter. ;-)

-- 
Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
