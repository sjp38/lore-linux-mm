Date: Fri, 27 Oct 2000 14:54:39 +0100 (BST)
From: James Sutherland <jas88@cam.ac.uk>
Subject: Re: Discussion on my OOM killer API
In-Reply-To: <20001027093908.B17142@viva.uti.hu>
Message-ID: <Pine.LNX.4.10.10010271449430.12564-100000@dax.joh.cam.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gabor Linart <lgb@viva.uti.hu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Oct 2000, Gabor Linart wrote:

> On Fri, Oct 27, 2000 at 07:46:31AM +0100, James Sutherland wrote:
> > Yes, that should keep most people happy; better still, it could try other
> > approaches before kill9: start shouting at the console when you're down to
> > the last 25Mb, disable logins at 10Mb and start SIGTERMing things at 5,
> > perhaps. Or maybe bring some "emergency" swapspace online and disable
> > non-root logins. That way, if the sysadmin responds quickly enough, they
> > can clear out whatever THEY think is causing a problem; if not, they'll
> > arrive to find a fully working machine with a couple of people complaining
> > about Netscape having crashed yet again, rather than an init-less
> > machine!
> 
> Sure. Implementing user-space OOM killer is much better because you can
> do everything you want to react for OOM case. In kernel it would be much
> more difficult to maintain and finetune, IMHO. BTW, it almost the same.
> If someone wants OOM API, SIGDANGER can be considered a "stupid API".
> And yes, everything should be removed from kernel space which can be done
> in user space easily (and don't open other thread on microkernels ;-)

Well, I'm certainly not going to start advocating microkernelising Linux!

I don't think we should remove OOM killer code from the kernel entirely,
though: supposing the oom killer dies (is killed by a malicious attacker,
unknown bug, whatever)? We MUST kill something, so we need a decent
kernel-side failsafe.

I'll make a start on coding a killer daemon soon. I think it should be the
party sending SIGDANGER (or whatever); if things get bad enough the
kernel-side killer is triggered, I think it should just blow the processes
up hard.


James.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
