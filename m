Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DAEF85F0001
	for <linux-mm@kvack.org>; Sat, 31 Jan 2009 16:28:12 -0500 (EST)
Date: Sat, 31 Jan 2009 22:27:55 +0100
From: Pavel Machek <pavel@suse.cz>
Subject: Re: marching through all physical memory in software
Message-ID: <20090131212754.GA15243@elf.ucw.cz>
References: <715599.77204.qm@web50111.mail.re2.yahoo.com> <m1wscc7fop.fsf@fess.ebiederm.org> <49836114.1090209@buttersideup.com> <m1iqnw1676.fsf@fess.ebiederm.org> <4984489C.8020309@buttersideup.com> <20090131134327.GB28763@khazad-dum.debian.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090131134327.GB28763@khazad-dum.debian.net>
Sender: owner-linux-mm@kvack.org
To: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Cc: Tim Small <tim@buttersideup.com>, "Eric W. Biederman" <ebiederm@xmission.com>, ncunningham-lkml@crca.org.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chris Friesen <cfriesen@nortel.com>, Doug Thompson <norsk5@yahoo.com>, bluesmoke-devel@lists.sourceforge.net, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>

Hi!

> And if an uncorretable error is detected during the scrub, we have to
> do something about it as well.  And that won't be that easy: locate
> whatever process is using that page, and so something smart to it...
> or do some emergency evasive actions if it is one of the kernel's data
> scructures, etc.
> 
> So, as you said, "background scrubbing" and "software scrubbing" really are
> very different things, and one has to expect that background scrubbing will
> eventually trigger software scrubbing, major system emergency handling
> (uncorrectable errors in kernel memory) or minor system emergency
> handling (uncorrectable errors in process memory).
> 
> > There is (AFAIK) no need to do any writes here, and in fact doing so is 
> 
> One might want the possibility of doing inconditional writes, because
> it helps with memory bitrot on crappy hardware where the refresh
> cycles aren't enough to avoid bitrot.  But you definately won't want
> it most of the time.
> 
> You can also implement software-based ECC using a background scrubber
> and setting aside pages to store the ECC information.  Now, THAT is
> probably not worth bothering with due to the performance impact, but
> who knows...

Actually, that would be quite cool. a) I suspect memory in  my zaurus
bitrots and b) bitroting memory over s2ram is apprently quite common.

									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
