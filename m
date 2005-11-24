Date: Thu, 24 Nov 2005 10:08:42 -0800 (PST)
From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Subject: Re: Kernel BUG at mm/rmap.c:491
In-Reply-To: <1132810499.1921.93.camel@mindpipe>
Message-ID: <Pine.LNX.4.61.0511241005180.16752@montezuma.fsmlabs.com>
References: <200511232256.jANMuGg20547@unix-os.sc.intel.com>
 <cone.1132788250.534735.25446.501@kolivas.org>  <200511232335.15050.s0348365@sms.ed.ac.uk>
  <20051124044009.GE30849@redhat.com> <1132810499.1921.93.camel@mindpipe>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Revell <rlrevell@joe-job.com>
Cc: Dave Jones <davej@redhat.com>, Alistair John Strachan <s0348365@sms.ed.ac.uk>, Con Kolivas <con@kolivas.org>, Kenneth W <kenneth.w.chen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 24 Nov 2005, Lee Revell wrote:

> On Wed, 2005-11-23 at 23:40 -0500, Dave Jones wrote:
> > The 'G' seems to confuse a hell of a lot of people.
> > (I've been asked about it when people got machine checks a lot over
> >  the last few months).
> > 
> > Would anyone object to changing it to conform to the style of
> > the other taint flags ? Ie, change it to ' ' ? 
> 
> While you're at it why not print a big loud warning that says not to
> post the Oops to LKML, and instructing the user to reproduce with a

I don't think wasting precious screen real estate on warnings is a good 
idea. The oops may also be of use, there have been occassions where the 
only oops output had a proprietary bit set. The person handling the bug 
report should be the one making the decision as to whether to repost a new 
oops.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
