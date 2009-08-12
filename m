Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 578326B004F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 06:54:12 -0400 (EDT)
Date: Wed, 12 Aug 2009 13:52:42 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv2 2/2] vhost_net: a kernel-level virtio server
Message-ID: <20090812105241.GA28848@redhat.com>
References: <cover.1249992497.git.mst@redhat.com> <20090811212802.GC26309@redhat.com> <4A82076A.1060805@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A82076A.1060805@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, hpa@zytor.com
List-ID: <linux-mm.kvack.org>

On Tue, Aug 11, 2009 at 08:06:02PM -0400, Gregory Haskins wrote:
> > diff --git a/include/linux/miscdevice.h b/include/linux/miscdevice.h
> > index 0521177..781a8bb 100644
> > --- a/include/linux/miscdevice.h
> > +++ b/include/linux/miscdevice.h
> > @@ -30,6 +30,7 @@
> >  #define HPET_MINOR		228
> >  #define FUSE_MINOR		229
> >  #define KVM_MINOR		232
> > +#define VHOST_NET_MINOR		233
> 
> Would recommend using DYNAMIC-MINOR.

Good idea. Thanks!

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
