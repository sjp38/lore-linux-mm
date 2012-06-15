Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id EC4C06B005C
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 03:40:40 -0400 (EDT)
Received: by obbta14 with SMTP id ta14so3791139obb.14
        for <linux-mm@kvack.org>; Fri, 15 Jun 2012 00:40:40 -0700 (PDT)
Message-ID: <1339746105.3321.15.camel@lappy>
Subject: Re: Early boot panic on machine with lots of memory
From: Sasha Levin <levinsasha928@gmail.com>
Date: Fri, 15 Jun 2012 09:41:45 +0200
In-Reply-To: <CAE9FiQWP0vWQCUV3MjEhpCEwUHRG38VQwEeVEN_mKtDZYo8eOw@mail.gmail.com>
References: <1339623535.3321.4.camel@lappy>
	 <20120614032005.GC3766@dhcp-172-17-108-109.mtv.corp.google.com>
	 <1339667440.3321.7.camel@lappy>
	 <CAE9FiQVJ-q3gQxfBqfRnG+RvEh2bZ2-Ki=CRUATmCKjJp8MNuw@mail.gmail.com>
	 <1339709672.3321.11.camel@lappy>
	 <CAE9FiQVXxnjccSErjrZ9B-APGf5ZpKNovJwr5vNBMr1G2f8Y4Q@mail.gmail.com>
	 <1339721952.3321.14.camel@lappy>
	 <CAE9FiQWP0vWQCUV3MjEhpCEwUHRG38VQwEeVEN_mKtDZYo8eOw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, hpa@linux.intel.com, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kvm <kvm@vger.kernel.org>, avi@redhat.com, Marcelo Tosatti <mtosatti@redhat.com>

On Thu, 2012-06-14 at 19:21 -0700, Yinghai Lu wrote:
> On Thu, Jun 14, 2012 at 5:59 PM, Sasha Levin <levinsasha928@gmail.com> wrote:
> > On Thu, 2012-06-14 at 16:57 -0700, Yinghai Lu wrote:
> >> can you please boot with "memtest" to see if there is any memory problem?
> >
> > The host got a memtest treatment, nothing found.
> 
> can you try to boot guest with memtest?

Tried that, memtest on guest didn't reveal anything but the guest
proceeded to crashing anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
