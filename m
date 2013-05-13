Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 6CD526B0085
	for <linux-mm@kvack.org>; Mon, 13 May 2013 15:21:22 -0400 (EDT)
Date: Mon, 13 May 2013 22:21:17 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC 2/2] virtio_balloon: auto-ballooning support
Message-ID: <20130513192117.GA3527@redhat.com>
References: <1368111229-29847-1-git-send-email-lcapitulino@redhat.com>
 <1368111229-29847-3-git-send-email-lcapitulino@redhat.com>
 <20130512143054.GI10144@redhat.com>
 <518FC4F9.5010505@redhat.com>
 <20130512184934.GA16334@redhat.com>
 <20130513110303.33dbaba6@redhat.com>
 <20130513151624.GB1992@redhat.com>
 <51910552.5050507@redhat.com>
 <20130513153513.GA4981@redhat.com>
 <51913A9B.2030807@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51913A9B.2030807@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, aquini@redhat.com, amit.shah@redhat.com, anton@enomsg.org

On Mon, May 13, 2013 at 03:10:19PM -0400, Rik van Riel wrote:
> On 05/13/2013 11:35 AM, Michael S. Tsirkin wrote:
> >On Mon, May 13, 2013 at 11:22:58AM -0400, Rik van Riel wrote:
> 
> >>I believe the Google patches still included some way for the
> >>host to initiate balloon inflation on the guest side, because
> >>the guest internal state alone is not enough to see when the
> >>host is under memory pressure.
> >>
> >>I discussed the project with the Google developers in question
> >>a little over a year ago, but I do not remember whether their
> >>pressure notification went through qemu, or directly from the
> >>host kernel to the guest kernel...
> >
> >So increasing the max number of pages in balloon
> >indicates host memory pressure to the guest?
> >Fair enough but I wonder whether there's a way to
> >make it more explicit in the interface, somehow.
> 
> There may be a better way to do this, but I am really not sure
> what that would be. What properties would you like to see in
> the interface? What kind of behaviour are you looking for?

I'd like to propagate what we know to the guest and
not require things we don't know.

Well for once, all we know is host is under memory pressure.
We don't really know how much memory should be freed.

So maybe we should just have a binary "host under memory
pressure" and have guest free what it can, e.g. have it
drop caches more aggressively.

> -- 
> All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
