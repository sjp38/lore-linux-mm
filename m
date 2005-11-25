Date: Fri, 25 Nov 2005 10:43:44 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Kernel BUG at mm/rmap.c:491
In-Reply-To: <200511251050.02833.kernel@kolivas.org>
Message-ID: <Pine.LNX.4.61.0511251040460.5479@goblin.wat.veritas.com>
References: <25093.1132876061@ocs3.ocs.com.au> <200511251050.02833.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Keith Owens <kaos@ocs.com.au>, Dave Jones <davej@redhat.com>, Alistair John Strachan <s0348365@sms.ed.ac.uk>, Kenneth W <kenneth.w.chen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 25 Nov 2005, Con Kolivas wrote:
> On Fri, 25 Nov 2005 10:47, Keith Owens wrote:
> > On Thu, 24 Nov 2005 07:50:49 +0000 (GMT),
> > Hugh Dickins <hugh@veritas.com> wrote:
> > >On Wed, 23 Nov 2005, Dave Jones wrote:
> > >>
> > >> The 'G' seems to confuse a hell of a lot of people.
> > >> (I've been asked about it when people got machine checks a lot over
> > >>  the last few months).
> > >>
> > >> Would anyone object to changing it to conform to the style of
> > >> the other taint flags ? Ie, change it to ' ' ?
> > >
> > >Please, please do: it's insane as is.  But I've CC'ed Keith,
> > >we sometimes find the kernel does things so to suit ksymoops.
> >
> > 'G' is not one of mine, I find it annoying as well.
> 
> Would anyone object to changing it so that tainted only means Proprietary 
> taint and use a different keyword for GPL tainting such as "Corrupted"?

I don't see the point.  The system is in a dubious state, tainted is
the word we've been using for that, the flags indicate what's suspect,
why play with the wording further?  But replace 'G' by ' ' certainly.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
