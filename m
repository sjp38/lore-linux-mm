Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 830CA6B0034
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 14:38:52 -0400 (EDT)
Date: Wed, 26 Jun 2013 11:38:51 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] zcache: initialize module properly when zcache=FOO is
 given
Message-ID: <20130626183851.GA10591@kroah.com>
References: <1372258142-7019-1-git-send-email-mhocko@suse.cz>
 <20130626150116.GA6004@phenom.dumpdata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20130626150116.GA6004@phenom.dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Michal Hocko <mhocko@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cristian =?iso-8859-1?Q?Rodr=EDguez?= <crrodriguez@opensuse.org>

On Wed, Jun 26, 2013 at 11:01:16AM -0400, Konrad Rzeszutek Wilk wrote:
> On Wed, Jun 26, 2013 at 04:49:02PM +0200, Michal Hocko wrote:
> > 835f2f51 (staging: zcache: enable zcache to be built/loaded as a module)
> > introduced in 3.10-rc1 has introduced a bug for zcache=FOO module
> > parameter processing.
> > 
> > zcache_comp_init return code doesn't agree with crypto_has_comp which
> > uses 1 for the success unlike zcache_comp_init which uses 0. This
> > causes module loading failure even if the given algorithm is supported:
> > [    0.815330] zcache: compressor initialization failed
> > 
> > Reported-by: Cristian Rodriguez <crrodriguez@opensuse.org>
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Looks OK to me.
> 
> Cc-ing Greg.

That's nice, but can someone resend it in a format that I can apply it
in, with your ack?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
