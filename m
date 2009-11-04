Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 965326B0044
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 13:09:15 -0500 (EST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv6 1/3] tun: export underlying socket
Date: Wed, 4 Nov 2009 19:09:05 +0100
References: <cover.1257193660.git.mst@redhat.com> <20091102222612.GB15184@redhat.com> <200911031312.33580.arnd@arndb.de>
In-Reply-To: <200911031312.33580.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200911041909.06054.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: virtualization@lists.linux-foundation.org
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com
List-ID: <linux-mm.kvack.org>

On Tuesday 03 November 2009, Arnd Bergmann wrote:
> > index 3f5fd52..404abe0 100644
> > --- a/include/linux/if_tun.h
> > +++ b/include/linux/if_tun.h
> > @@ -86,4 +86,18 @@ struct tun_filter {
> >         __u8   addr[0][ETH_ALEN];
> >  };
> >  
> > +#ifdef __KERNEL__
> > +#if defined(CONFIG_TUN) || defined(CONFIG_TUN_MODULE)
> > +struct socket *tun_get_socket(struct file *);
> > +#else
> > +#include <linux/err.h>
> > +#include <linux/errno.h>
> > +struct file;
> > +struct socket;
> > +static inline struct socket *tun_get_socket(struct file *f)
> > +{
> > +       return ERR_PTR(-EINVAL);
> > +}
> > +#endif /* CONFIG_TUN */
> > +#endif /* __KERNEL__ */
> >  #endif /* __IF_TUN_H */
> 
> Is this a leftover from testing? Exporting the function for !__KERNEL__
> seems pointless.
> 

Michael, you didn't reply on this comment and the code is still there in v8.
Do you actually need this? What for?

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
