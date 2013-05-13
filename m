Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 4BFF06B008C
	for <linux-mm@kvack.org>; Mon, 13 May 2013 16:01:29 -0400 (EDT)
Date: Mon, 13 May 2013 16:01:26 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [RFC 2/2] virtio_balloon: auto-ballooning support
Message-ID: <20130513160126.4d196719@redhat.com>
In-Reply-To: <20130513190250.GA2496@redhat.com>
References: <1368111229-29847-1-git-send-email-lcapitulino@redhat.com>
	<1368111229-29847-3-git-send-email-lcapitulino@redhat.com>
	<20130509211516.GC16446@optiplex.redhat.com>
	<20130510092046.17be9bbb@redhat.com>
	<20130513143441.GA13910@optiplex.redhat.com>
	<20130513142511.3c2bde18@redhat.com>
	<20130513190250.GA2496@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, riel@redhat.com, amit.shah@redhat.com, anton@enomsg.org

On Mon, 13 May 2013 22:02:50 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Mon, May 13, 2013 at 02:25:11PM -0400, Luiz Capitulino wrote:
> > On Mon, 13 May 2013 11:34:41 -0300
> > Rafael Aquini <aquini@redhat.com> wrote:
> > 
> > > You're right, and the host's member is used to communicate the configured size
> > > to guest's balloon device, however, by not changing it when the shrinker causes 
> > > the balloon to deflate will make the balloon thread to be woken up again 
> > > in order to chase the balloon size target again, won't it? Check
> > 
> > I don't see the balloon thread waking up after the shrinker executes in my
> > testing. Maybe this is so because it will only wake up when QEMU notifies
> > a config change.
> 
> Well that's also a problem.
> Need some mechanism to re-inflate balloon

In this implemention this is done by QEMU, have you looked at the QEMU
patch yet?

 https://lists.gnu.org/archive/html/qemu-devel/2013-05/msg01295.html

> when guest memory pressure is down.

In this implementation we do this when there's pressure in the host. I expect
things to balance over time, and this seems to be what I'm observing in my
testing, but of course we need more testing.

> virtio fs mechanism worth a look?

Can you elaborate?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
