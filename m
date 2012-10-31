Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 138216B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 04:37:24 -0400 (EDT)
From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH v3 2/6] PM / Runtime: introduce pm_runtime_set[get]_memalloc_noio()
Date: Wed, 31 Oct 2012 09:37:16 +0100
Message-ID: <1478330.G3nm4yCX9h@linux-lqwf.site>
In-Reply-To: <CACVXFVNxucCVLS-=EQkmVop3LQMkeXW7RbZq4yfkiq_MUGndvg@mail.gmail.com>
References: <CACVXFVOPDu6wVgPmvtTkokn7VV41x3XVvL4g_E0pz0mikUbvUg@mail.gmail.com> <CACVXFVMRJPfPSC_4ZamqfYUSYNsMEVYXMFmcs26T=4MdB_Kntw@mail.gmail.com> <CACVXFVNxucCVLS-=EQkmVop3LQMkeXW7RbZq4yfkiq_MUGndvg@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: Alan Stern <stern@rowland.harvard.edu>, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On Wednesday 31 October 2012 11:05:33 Ming Lei wrote:
> On Wed, Oct 31, 2012 at 10:08 AM, Ming Lei <ming.lei@canonical.com> wrote:
> >> I am afraid it is, because a disk may just have been probed as the deviceis being reset.
> >
> > Yes, it is probable, and sounds like similar with 'root_wait' problem, see
> > prepare_namespace(): init/do_mounts.c, so looks no good solution
> > for the problem, and maybe we have to set the flag always before resetting
> > usb device.
> 
> The below idea may help the problem which 'memalloc_noio' flag isn't set during
> usb_reset_device().
> 
> - for usb mass storage device, call pm_runtime_set_memalloc_noio(true)
>   inside usb_stor_probe2() and uas_probe(), and call
>   pm_runtime_set_memalloc_noio(false) inside uas_disconnect()
>   and usb_stor_disconnect().
> 
> - for usb network device, register_netdev() is always called inside usb
>   interface's probe(),  looks no such problem.

This still leaves networking done over PPP in the cold.

	Regards
		Oliver

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
