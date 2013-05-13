Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id B8A766B0033
	for <linux-mm@kvack.org>; Mon, 13 May 2013 14:25:15 -0400 (EDT)
Date: Mon, 13 May 2013 14:25:11 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [RFC 2/2] virtio_balloon: auto-ballooning support
Message-ID: <20130513142511.3c2bde18@redhat.com>
In-Reply-To: <20130513143441.GA13910@optiplex.redhat.com>
References: <1368111229-29847-1-git-send-email-lcapitulino@redhat.com>
	<1368111229-29847-3-git-send-email-lcapitulino@redhat.com>
	<20130509211516.GC16446@optiplex.redhat.com>
	<20130510092046.17be9bbb@redhat.com>
	<20130513143441.GA13910@optiplex.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, riel@redhat.com, mst@redhat.com, amit.shah@redhat.com, anton@enomsg.org

On Mon, 13 May 2013 11:34:41 -0300
Rafael Aquini <aquini@redhat.com> wrote:

> You're right, and the host's member is used to communicate the configured size
> to guest's balloon device, however, by not changing it when the shrinker causes 
> the balloon to deflate will make the balloon thread to be woken up again 
> in order to chase the balloon size target again, won't it? Check

I don't see the balloon thread waking up after the shrinker executes in my
testing. Maybe this is so because it will only wake up when QEMU notifies
a config change.

But anyway, I'll think how to improve this as suggested by Michael too, as
I seem to be changing num_pages' semantics according to the virtio spec.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
