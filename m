Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B795B6B004F
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 07:03:30 -0400 (EDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv4 2/2] vhost_net: a kernel-level virtio server
Date: Thu, 27 Aug 2009 20:33:26 +0930
References: <cover.1250693417.git.mst@redhat.com> <200908261540.59900.arnd@arndb.de> <20090827101026.GA8545@redhat.com>
In-Reply-To: <20090827101026.GA8545@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200908272033.26540.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hpa@zytor.com, mingo@elte.hu, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Aug 2009 07:40:26 pm Michael S. Tsirkin wrote:
> On Wed, Aug 26, 2009 at 03:40:59PM +0200, Arnd Bergmann wrote:
> > On Tuesday 25 August 2009, Michael S. Tsirkin wrote:
> > > >  I'd like to avoid that here,
> > > > though it's kind of ugly.  We'd need VHOST_GET_FEATURES (and ACK) to take a
> > > > struct like:
> > > > 
> > > >       u32 feature_size;
> > > >       u32 features[];
> > 
> > Hmm, variable length ioctl arguments, I'd rather not go there.
> > The ioctl infrastructure already has a length argument encoded
> > in the ioctl number. We can use that if we need more, e.g.
> > 
> > /* now */
> > #define VHOST_GET_FEATURES     _IOR(VHOST_VIRTIO, 0x00, __u64)
> > /*
> >  * uncomment if we run out of feature bits:
> > 
> > struct vhost_get_features2 {
> > 	__u64 bits[2];
> > };
> > #define VHOST_GET_FEATURES2     _IOR(VHOST_VIRTIO, 0x00, \
> > 			struct  vhost_get_features2)
> >  */
> 
> 
> I thought so, too. Rusty, agree?

Yep, am convinced.  Make it u64 to stop us having to do this tomorrow, then
we can always extend later.

Thanks,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
