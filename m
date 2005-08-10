From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC][PATCH] Rename PageChecked as PageMiscFS
Date: Wed, 10 Aug 2005 18:06:09 +1000
References: <42F57FCA.9040805@yahoo.com.au> <200508100923.55749.phillips@arcor.de> <Pine.LNX.4.61.0508100843420.18223@goblin.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.61.0508100843420.18223@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508101806.09532.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 10 August 2005 17:48, Hugh Dickins wrote:
> On Wed, 10 Aug 2005, Daniel Phillips wrote:
> > --- 2.6.13-rc5-mm1.clean/include/linux/page-flags.h	2005-08-09
> > 18:23:31.000000000 -0400 +++
> > 2.6.13-rc5-mm1/include/linux/page-flags.h	2005-08-09 18:59:57.000000000
> > -0400 @@ -61,7 +61,7 @@
> >  #define PG_active		 6
> >  #define PG_slab			 7	/* slab debug (Suparna wants this) */
> >
> > -#define PG_checked		 8	/* kill me in 2.5.<early>. */
> > +#define PG_miscfs		 8	/* kill me in 2.5.<early>. */
> >  #define PG_fs_misc		 8
>
> And all those PageMiscFS macros you're adding to the PageFsMisc ones:
> doesn't look like progress to me ;)

Heh, it looks like part of a patch did creep into Andrew's tree already.  I'll 
fix it on the morrow.

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
