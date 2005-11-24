From: Con Kolivas <kernel@kolivas.org>
Subject: Re: Kernel BUG at mm/rmap.c:491
Date: Fri, 25 Nov 2005 10:50:01 +1100
References: <25093.1132876061@ocs3.ocs.com.au>
In-Reply-To: <25093.1132876061@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511251050.02833.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Keith Owens <kaos@ocs.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Dave Jones <davej@redhat.com>, Alistair John Strachan <s0348365@sms.ed.ac.uk>, Kenneth W <kenneth.w.chen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 25 Nov 2005 10:47, Keith Owens wrote:
> On Thu, 24 Nov 2005 07:50:49 +0000 (GMT),
>
> Hugh Dickins <hugh@veritas.com> wrote:
> >On Wed, 23 Nov 2005, Dave Jones wrote:
> >> On Wed, Nov 23, 2005 at 11:35:15PM +0000, Alistair John Strachan wrote:
> >>  > On Wednesday 23 November 2005 23:24, Con Kolivas wrote:
> >>  > > Chen, Kenneth W writes:
> >>  > > > Has people seen this BUG_ON before?  On 2.6.15-rc2, x86-64.
> >>  > > >
> >>  > > > Pid: 16500, comm: cc1 Tainted: G    B 2.6.15-rc2 #3
> >>  > > >
> >>  > > > Pid: 16651, comm: sh Tainted: G    B 2.6.15-rc2 #3
> >>  > >
> >>  > >                        ^^^^^^^^^^
> >>  > >
> >>  > > Please try to reproduce it without proprietary binary modules
> >>  > > linked in.
> >>  >
> >>  > AFAIK "G" means all loaded modules are GPL, P is for proprietary
> >>  > modules.
> >>
> >> The 'G' seems to confuse a hell of a lot of people.
> >> (I've been asked about it when people got machine checks a lot over
> >>  the last few months).
> >>
> >> Would anyone object to changing it to conform to the style of
> >> the other taint flags ? Ie, change it to ' ' ?
> >
> >Please, please do: it's insane as is.  But I've CC'ed Keith,
> >we sometimes find the kernel does things so to suit ksymoops.
>
> 'G' is not one of mine, I find it annoying as well.

Would anyone object to changing it so that tainted only means Proprietary 
taint and use a different keyword for GPL tainting such as "Corrupted"?

Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
