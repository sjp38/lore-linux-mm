Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 2A7F36B0074
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 09:15:35 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so7601034vbk.14
        for <linux-mm@kvack.org>; Fri, 06 Jul 2012 06:15:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120705141700.GI3399@mudshark.cambridge.arm.com>
References: <1341412376-6272-1-git-send-email-will.deacon@arm.com>
	<CAJd=RBAmF3dtb8wtEbS-A7BNT=RLsb5emQQWVU8ioeQOO8D7NA@mail.gmail.com>
	<20120705141700.GI3399@mudshark.cambridge.arm.com>
Date: Fri, 6 Jul 2012 21:15:34 +0800
Message-ID: <CAJd=RBC+foz61E733P8jkkwPqAkdFjYc_9uYza67Z=n3=7bv-A@mail.gmail.com>
Subject: Re: [PATCH] mm: hugetlb: flush dcache before returning zeroed huge
 page to userspace
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Jul 5, 2012 at 10:17 PM, Will Deacon <will.deacon@arm.com> wrote:
>
> Which tree does this stuff usually go through?

mm --> next --> linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
