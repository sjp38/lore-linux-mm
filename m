Date: Thu, 11 Sep 2003 23:50:54 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: ide-scsi oops was: 2.6.0-test4-mm3
Message-ID: <20030911215054.GL12021@suse.de>
References: <20030910114346.025fdb59.akpm@osdl.org> <10720000.1063224243@flay> <20030911082057.GP1396@suse.de> <1063294049.2967.30.camel@dhcp23.swansea.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1063294049.2967.30.camel@dhcp23.swansea.linux.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Andrew Morton <akpm@osdl.org>, Mike Fedyk <mfedyk@matchmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 11 2003, Alan Cox wrote:
> On Iau, 2003-09-11 at 09:20, Jens Axboe wrote:
> > > need it. Is it unfixable? or just nobody's done it?
> > 
> > It's not unfixable, there's just not a lot of motivation to fix it since
> > it's basically dead.
> 
> Almost all IDE tape drives require ide-scsi/st modules for one.  I'm not

Big deal, 99% of ide-scsi use is for cd burning. But yes, it should be
fixed. I'm not disagreeing, I just don't think it's a high prio item.
And apparently noone else thinks so either, if not it would have been
fixed a long time ago (it's been broken for how long now?)

> sure of the problems in the 2.5 case, in the 2.4 case the big one was
> that both IDE and SCSI want to control reset/recovery and reissue of
> commands. That turns into a nasty mess and 2.4 now lets the IDE layer do
> it, with SCSI just backing off. That may well be the right model for
> 2.5.x - ie the reset eh handler just waits for the IDE layer to kill the
> command. The other one was races in the reset code which 2.4 I think now
> has fixed, which will bite non scsi users but less often

Just needs someone to do it. Once it bugs someone enough, that someone
will do it. Until then, it remains broken :)

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
