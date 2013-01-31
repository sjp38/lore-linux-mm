Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id C76976B0007
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 19:05:47 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id bi1so1372509pad.22
        for <linux-mm@kvack.org>; Wed, 30 Jan 2013 16:05:47 -0800 (PST)
Message-ID: <1359590736.1557.0.camel@kernel>
Subject: Re: [PATCH 0/11] ksm: NUMA trees and page migration
From: Ric Mason <ric.masonn@gmail.com>
Date: Wed, 30 Jan 2013 18:05:36 -0600
In-Reply-To: <20130129165125.GA17671@redhat.com>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
	 <20130128155452.16882a6e.akpm@linux-foundation.org>
	 <51071CA0.801@ravellosystems.com> <51073345.4070605@ravellosystems.com>
	 <20130129165125.GA17671@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Izik Eidus <izik.eidus@ravellosystems.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Petr Holasek <pholasek@redhat.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Anton Arapov <anton@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2013-01-29 at 17:51 +0100, Andrea Arcangeli wrote:
> Hi everyone,
> 
> On Tue, Jan 29, 2013 at 04:26:13AM +0200, Izik Eidus wrote:
> > On 01/29/2013 02:49 AM, Izik Eidus wrote:
> > > On 01/29/2013 01:54 AM, Andrew Morton wrote:
> > >> On Fri, 25 Jan 2013 17:53:10 -0800 (PST)
> > >> Hugh Dickins <hughd@google.com> wrote:
> > >>
> > >>> Here's a KSM series
> > >> Sanity check: do you have a feeling for how useful KSM is?
> > >> Performance/space improvements for typical (or atypical) workloads?
> > >> Are people using it?  Successfully?
> > 
> > 
> > BTW, After thinking a bit about the word people, I wanted to see if 
> > normal users of linux
> > that just download and install Linux (without using special 
> > virtualization product) are able to use it.
> > So I google little bit for it, and found some nice results from users:
> > http://serverascode.com/2012/11/11/ksm-kvm.html
> > 
> > But I do agree that it provide justifying value only for virtualization 
> > users...
> 
> Mostly for virtualization users indeed, but I'm aware of a few non
> virtualization users too:
> 
> 1) CERN has been one of the early adopters of KSM and initially they
> were using KSM standalone (probably because not all hypervisors they
> had to deal with were KVM/linux based, while all guests were linux and
> in turn KSM capable). More info in the KSM paper page 2:
> 
> http://www.kernel.org/doc/ols/2009/ols2009-pages-19-28.pdf
> 
> However lately they're running KSM in combination with KVM too, and I'm
> not sure if they're still using it standalone. See the "KSM shared"
> blue area in slide 12 and the comparison with KSM on and off in slide
> 14.
> 
> https://indico.fnal.gov/getFile.py/access?contribId=18&sessionId=4&resId=0&materialId=slides&confId=4986
> 
> 2) all recent cyanogenmod in the performance menu in settings supports
> KSM out of the box. You can run it for a while and then shut it
> off.
> 
> Not sure how good idea it is to leave it always on, but the only
> efficient cellphone/tablet powersaving design (i.e. the wakelocks +
> suspend to ram) still won't waste energy while the screen is off and
> the phone has suspended to ram, regardless of KSM on or off.
> 
> KSM NUMA awareness however is not needed on the cellphone :).

Thanks for your sharing. Is there ksm benchmark? How to get it?

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
