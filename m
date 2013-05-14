From: Dmitry Maluka <D.Maluka@adbglobal.com>
Subject: Re: Yet another page fault deadlock
Date: Tue, 14 May 2013 18:38:02 +0300
Message-ID: <kmtlsf$bjf$1@ger.gmane.org>
References: <kmrak0$ip1$1@ger.gmane.org> <CACVXFVNQVbe6MjWd9sH4wMK9fRCqxdvX2qSrep9GPfPPWOJ54A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACVXFVNQVbe6MjWd9sH4wMK9fRCqxdvX2qSrep9GPfPPWOJ54A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Thanks for the remarks.

On 05/14/2013 01:32 PM, Ming Lei wrote:
> If the user buffer passed to driver A is mapped against file on the block
> device, single thread 1 may still deadlock on the mutex A.

Good point, thanks. It is unlikely to ever be a use case for us, but
still worth considering for the driver robustness.

> It can't be avoided 100% with the memset() workaround since the user
> buffer might be swapped out.

Yep. We have swap disabled though, so this should be fine as a temporary
workaround.

> Looks there are some similar examples, one of them is b31ca3f5df( sysfs:
> fix deadlock).
> 
> ...
> 
> Maybe it is good to document the lock usage, but the rule isn't much
> complicated: if one lock may be held under mmap_sem, the lock can't be
> held before copy_to/from_user(), :-)

Ok. I see it is a known pitfall. Still, it would be nice if people could
discover it not via a posteriori deadlocks debugging and lurking in list
archives. :)
