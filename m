Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CB4DD5F0001
	for <linux-mm@kvack.org>; Sat, 31 Jan 2009 20:25:57 -0500 (EST)
Date: Sat, 31 Jan 2009 23:25:53 -0200
From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: marching through all physical memory in software
Message-ID: <20090201012553.GB22841@khazad-dum.debian.net>
References: <715599.77204.qm@web50111.mail.re2.yahoo.com> <m1wscc7fop.fsf@fess.ebiederm.org> <49836114.1090209@buttersideup.com> <m1iqnw1676.fsf@fess.ebiederm.org> <4984489C.8020309@buttersideup.com> <20090131134327.GB28763@khazad-dum.debian.net> <20090131212754.GA15243@elf.ucw.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090131212754.GA15243@elf.ucw.cz>
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@suse.cz>
Cc: Tim Small <tim@buttersideup.com>, "Eric W. Biederman" <ebiederm@xmission.com>, ncunningham-lkml@crca.org.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chris Friesen <cfriesen@nortel.com>, Doug Thompson <norsk5@yahoo.com>, bluesmoke-devel@lists.sourceforge.net, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>

On Sat, 31 Jan 2009, Pavel Machek wrote:
> > You can also implement software-based ECC using a background scrubber
> > and setting aside pages to store the ECC information.  Now, THAT is
> > probably not worth bothering with due to the performance impact, but
> > who knows...
> 
> Actually, that would be quite cool. a) I suspect memory in  my zaurus
> bitrots and b) bitroting memory over s2ram is apprently quite common.

Well, software-based ECC for s2ram (calculate right before s2ram,
check-and-fix right after waking up) is certainly doable and a LOT
easier than my crazy idea of sofware-based generic ECC (which requires
some sort of trick to detect pages that were written to, so that you
can update their ECC information)...

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
