Subject: Re: 2.5.44-mm2 CONFIG_SHAREPTE necessary for starting KDE 3.0.3
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <1035310234.1044.1480.camel@phantasy>
References: <1035306108.13078.178.camel@spc9.esa.lanl.gov>
	<1035307236.13083.183.camel@spc9.esa.lanl.gov>
	<1035310234.1044.1480.camel@phantasy>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 22 Oct 2002 13:02:23 -0600
Message-Id: <1035313343.13140.221.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: Andrew Morton <akpm@zip.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2002-10-22 at 12:10, Robert Love wrote:
> On Tue, 2002-10-22 at 13:20, Steven Cole wrote:
> 
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

The above is correct.  Plus

	!CONFIG_PREEMPT + CONFIG_SHAREPTE => OK (tested).
	
> 
> Sounds like a timing issue to me.  Any other errors?  It is possible to
> get a trace?

Maybe, but unfortunately I'll be away from kernel testing until later
this week. Sorry.  I've got to catch up on some other stuff. 

Other errors, yes, but not always easily reproducible.  Nothing bad seen
in console mode, but under X (when KDE can start), after a while the
Konsoles don't respond to the keyboard (mouse OK), and after more time,
a moved window doesn't refresh (blank inside), and after that I can't
move from one virtual desktop to another.  Early after booting, I can
successfully ssh to the box, but after it starts falling apart, I
cannot.  I get the response from the sshd for my password, but nothing
after that. This is all with KDE running.  I haven't done much testing
with Gnome, apart from determining that it did not fail with
CONFIG_PREEMPT + !CONFIG_SHAREPTE as KDE 3.0.3 did.

> 
> This sounds familiar, so do not think too hard without double
> checking... someone else reported failure with KDE.

Yes, but I believe that was an opposite report, that KDE failed with
CONFIG_SHAREPTE=y.

Very strange.

Steven



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
