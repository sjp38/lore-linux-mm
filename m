Date: Tue, 28 Jun 2005 07:02:26 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [RFC] Fix SMP brokenness for PF_FREEZE and make freezing usable
 for other purposes
In-Reply-To: <42C10690.10108@sw.ru>
Message-ID: <Pine.LNX.4.62.0506280701560.6114@graphe.net>
References: <Pine.LNX.4.62.0506241316370.30503@graphe.net>
 <20050625025122.GC22393@atrey.karlin.mff.cuni.cz> <Pine.LNX.4.62.0506242311220.7971@graphe.net>
 <20050626023053.GA2871@atrey.karlin.mff.cuni.cz> <Pine.LNX.4.62.0506251954470.26198@graphe.net>
 <20050626030925.GA4156@atrey.karlin.mff.cuni.cz> <Pine.LNX.4.62.0506261928010.1679@graphe.net>
 <Pine.LNX.4.58.0506262121070.19755@ppc970.osdl.org>
 <Pine.LNX.4.62.0506262249080.4374@graphe.net> <20050627141320.GA4945@atrey.karlin.mff.cuni.cz>
 <Pine.LNX.4.62.0506270804450.17400@graphe.net> <42C0EBAB.8070709@sw.ru>
 <Pine.LNX.4.62.0506272323490.30956@graphe.net> <42C0FCB3.4030205@sw.ru>
 <42C10690.10108@sw.ru>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kirill Korotaev <dev@sw.ru>
Cc: Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, raybry@engr.sgi.com, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
List-ID: <linux-mm.kvack.org>

On Tue, 28 Jun 2005, Kirill Korotaev wrote:

> Christoph I was wrong a bit. Due to use of completion you have no one race I
> described before. If the task is leaving refrigarator with TIF_FREEZE it will
> just visit refrigarator() once more, but won't sleep there  since completion
> is done. BTW, I see no place where you initialize the completion.

It is initialized through the DECLARE_COMPLETION in sched.c.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
