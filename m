From: Con Kolivas <kernel@kolivas.org>
Subject: Re: o1-interactivity.patch (was Re: 2.5.74-mm1)
Date: Thu, 3 Jul 2003 23:30:42 +1000
References: <20030703023714.55d13934.akpm@osdl.org> <6u65mjkayg.fsf@zork.zork.net>
In-Reply-To: <6u65mjkayg.fsf@zork.zork.net>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200307032330.42311.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sean Neakums <sneakums@zork.net>, Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jul 2003 23:15, Sean Neakums wrote:
> Andrew Morton <akpm@osdl.org> writes:
> > . Included Con's CPU scheduler changes.  Feedback on the effectiveness of
> >   this and the usual benchmarks would be interesting.
>
> I find that this patch makes X really choppy when Mozilla Firebird is
> loading a page (which it does through an ssh tunnel here).  Both the X
> pointer and the spinner in the tab that is loading stop and start, for
> up to a second at a time.

Thanks for the feedback. I know about and am working on this one. No mention 
of the rest of the performance?

Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
