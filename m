Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.44-mm2 CONFIG_SHAREPTE necessary for starting KDE 3.0.3
Date: Tue, 22 Oct 2002 17:51:21 -0400
References: <1035306108.13078.178.camel@spc9.esa.lanl.gov> <1035307236.13083.183.camel@spc9.esa.lanl.gov> <1035310234.1044.1480.camel@phantasy>
In-Reply-To: <1035310234.1044.1480.camel@phantasy>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200210221751.21283.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>, Steven Cole <scole@lanl.gov>
Cc: Steven Cole <elenstev@mesatop.com>, Andrew Morton <akpm@zip.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On October 22, 2002 02:10 pm, Robert Love wrote:
> On Tue, 2002-10-22 at 13:20, Steven Cole wrote:
> > After reading my own mail, I realized that I should have checked to see
> > if disabling PREEMPT did any good in this case.
> >
> > I just booted 2.5.44-mm2 without PREEMPT and without SHAREPTE, and KDE
> > 3.0.3 was able to start up OK.
>
> Let me clarify, because this is odd...
>
> 	CONFIG_PREEMPT + CONFIG_SHAREPTE => OK
>
> 	CONFIG_PREEMPT + !CONFIG_SHAREPTE => KDE crashes
>
> 	!CONFIG_PREEMPT + !CONFIG_SHAREPTE => OK
>
> Right?
>
> Sounds like a timing issue to me.  Any other errors?  It is possible to
> get a trace?
>
> This sounds familiar, so do not think too hard without double
> checking... someone else reported failure with KDE.

Yes, I have been reporting problems since day one.  Also sent a few
straces which seem not to have help much.  In my case:

	CONFIG_PREEMPT + CONFIG_SHAREPTE => Fail

	CONFIG_PREEMPT 	!CONFIG_SHAREPTE => Works

Fun huh?
Ed Tomlinson
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
