Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 7E2F46B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 22:21:34 -0400 (EDT)
Received: by dakp5 with SMTP id p5so4087305dak.14
        for <linux-mm@kvack.org>; Thu, 14 Jun 2012 19:21:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1339721952.3321.14.camel@lappy>
References: <1339623535.3321.4.camel@lappy>
	<20120614032005.GC3766@dhcp-172-17-108-109.mtv.corp.google.com>
	<1339667440.3321.7.camel@lappy>
	<CAE9FiQVJ-q3gQxfBqfRnG+RvEh2bZ2-Ki=CRUATmCKjJp8MNuw@mail.gmail.com>
	<1339709672.3321.11.camel@lappy>
	<CAE9FiQVXxnjccSErjrZ9B-APGf5ZpKNovJwr5vNBMr1G2f8Y4Q@mail.gmail.com>
	<1339721952.3321.14.camel@lappy>
Date: Thu, 14 Jun 2012 19:21:33 -0700
Message-ID: <CAE9FiQWP0vWQCUV3MjEhpCEwUHRG38VQwEeVEN_mKtDZYo8eOw@mail.gmail.com>
Subject: Re: Early boot panic on machine with lots of memory
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, hpa@linux.intel.com, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kvm <kvm@vger.kernel.org>, avi@redhat.com, Marcelo Tosatti <mtosatti@redhat.com>

On Thu, Jun 14, 2012 at 5:59 PM, Sasha Levin <levinsasha928@gmail.com> wrote:
> On Thu, 2012-06-14 at 16:57 -0700, Yinghai Lu wrote:
>> can you please boot with "memtest" to see if there is any memory problem?
>
> The host got a memtest treatment, nothing found.

can you try to boot guest with memtest?

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
