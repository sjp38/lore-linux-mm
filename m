Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2EFEB6B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 17:58:11 -0500 (EST)
Message-ID: <4EB8625C.8020109@parallels.com>
Date: Mon, 7 Nov 2011 20:57:32 -0200
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] tmpfs: support user quotas
References: <1320614101.3226.5.camel@offbook> <20111107112952.GB25130@tango.0pointer.de> <1320675607.2330.0.camel@offworld> <20111107135823.3a7cdc53@lxorguk.ukuu.org.uk> <CAPXgP117Wkgvf1kDukjWt9yOye8xArpyX29xx36NT++s8TS5Rw@mail.gmail.com> <20111107225314.0e3976a6@lxorguk.ukuu.org.uk>
In-Reply-To: <20111107225314.0e3976a6@lxorguk.ukuu.org.uk>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Kay Sievers <kay.sievers@vrfy.org>, Davidlohr Bueso <dave@gnu.org>, Lennart Poettering <mzxreary@0pointer.de>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 11/07/2011 08:53 PM, Alan Cox wrote:
>> What part of the message did you read? This is about _per_user_
>> limits, not global limits!
>
> What part of 'we support lots of mounts' don't you understand. Or perhaps
> you could go use a control group for it ?

We are trying to implement an indirect limit on slab objects in the 
memory controller.
Our specific use case is to control the number of dentries currently 
pinned in some given physical filesystem. If you can't allocate a dentry 
from the dentry cache, you can also not DoS a system - in our case, a 
container.

Maybe this will also solve your problems?

>> Any untrusted user can fill /dev/shm today and DOS many services that
>> way on any machine out there. Same for /tmp when it's a tmpfs, or
>> /run/user. This is an absolutely unacceptable state and needs fixing.
>
> Actually if you've mounted it with limits they can be a nuisance but
> little more, and if you are running with memory overcommit disabled then
> its accounted for in that. If you are running with memory over commit
> allowed (as eg Red Hat and Fedora do) you are peeing into the wind at this
> point anyway so wasting time.
>
>> I don't care about which interface it is, if someting else fits
>> better, let's discuss that, but it has surely absolutely noting to do
>> with size/nr_blocks/nr_inodes.
>
> Per user would be quota, per process would be rlimit. Quite simple
> really, nice standard interfaces we've had for years. Various systems
> have been quotaing /tmp/ for a long time. Smart secure ones of course
> mount a per user /tmp via PAM or similar to avoid /tmp attacks and in that
> case the mount options I pointed out already do the job.
>
> Quota isn't entirely trivial because you want your quota db initialised
> at mount so you'd need to pass a quota file pointer to the mount command
> ideally. All doable however and makes the management easy and means you
> get all the application expected behaviour when you exceed your limits
> (that is for properly written stuff - lots of crappy badly written desktop
> programs randomly crash or worse as we already know)
>
> This is why I'm confused - you are wittering about all sorts of security
> stuff but you are not addressing the more serious matters first - the
> ones that go beyond a DoS.
>
> Alan
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
