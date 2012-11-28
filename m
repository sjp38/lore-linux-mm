Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 37BA96B004D
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 05:10:21 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH v6 2/6] PM / Runtime: introduce pm_runtime_set_memalloc_noio()
Date: Wed, 28 Nov 2012 11:15:05 +0100
Message-ID: <2662154.Tcp7v84XkT@vostro.rjw.lan>
In-Reply-To: <CACVXFVOk45wr8jv3w=KO7uTThGSTSkq0FRsPD6p_AyQZLWGQJg@mail.gmail.com>
References: <1353761958-12810-1-git-send-email-ming.lei@canonical.com> <1408044.6czCGhbHJH@vostro.rjw.lan> <CACVXFVOk45wr8jv3w=KO7uTThGSTSkq0FRsPD6p_AyQZLWGQJg@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-mm@kvack.org

On Wednesday, November 28, 2012 05:47:18 PM Ming Lei wrote:
> On Wed, Nov 28, 2012 at 5:29 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> >
> > But it doesn't have to walk the children.  Moreover, with counters it only
> 
> Yeah, I got it, it is the advantage of counter, but with extra 'int'
> field introduced
> in 'struct device'.
> 
> > needs to walk the whole path if all devices in it need to be updated.  For
> > example, if you call pm_runtime_set_memalloc_noio(dev, true) for a device
> > whose parent's counter is greater than zero already, you don't need to
> > walk the path above the parent.
> 
> We still can do it with the flag only, pm_runtime_set_memalloc_noio(dev, true)
> can return immediately if one parent or the 'dev' flag is true.
> 
> But considered that the pm_runtime_set_memalloc_noio(dev, false) is only
> called in a very infrequent path(network/block device->remove()), looks the
> introduced cost isn't worthy of the obtained advantage.
> 
> So could you accept not introducing counter? and I will update with the
> above improvement you suggested.

Well, please see my other message I sent a while ago. :-)

Thanks,
Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
