Date: Wed, 21 Nov 2001 10:56:31 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: recursive lock-enter-deadlock
Message-ID: <20011121105631.B2500@redhat.com>
References: <XFMail.20011121111913.R.Oehler@GDImbH.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <XFMail.20011121111913.R.Oehler@GDImbH.com>; from R.Oehler@GDImbH.com on Wed, Nov 21, 2001 at 11:19:13AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: R.Oehler@GDImbH.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Nov 21, 2001 at 11:19:13AM +0100, R.Oehler@GDImbH.com wrote:
> A short question (I don't have a recent 2.4.x at hand, currently):
> 
> Is this recursive lock-enter-deadlock (2.4.0) fixed in newer kernels?

Yes.  Seriously, 2.4.0 is so old and so full of bugs like this that
it's really not worth spending any effort looking for problems like
that in it.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
