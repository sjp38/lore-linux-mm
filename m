Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id l5FI7J45003852
	for <linux-mm@kvack.org>; Fri, 15 Jun 2007 19:07:19 +0100
Received: from py-out-1112.google.com (pygy77.prod.google.com [10.34.226.77])
	by spaceape7.eur.corp.google.com with ESMTP id l5FI5NAJ002516
	for <linux-mm@kvack.org>; Fri, 15 Jun 2007 19:07:15 +0100
Received: by py-out-1112.google.com with SMTP id y77so1848701pyg
        for <linux-mm@kvack.org>; Fri, 15 Jun 2007 11:07:15 -0700 (PDT)
Message-ID: <65dd6fd50706151107v784a252aw89a128f255304ef6@mail.gmail.com>
Date: Fri, 15 Jun 2007 11:07:15 -0700
From: "Ollie Wild" <aaw@google.com>
Subject: Re: [patch 0/3] no MAX_ARG_PAGES -v2
In-Reply-To: <1181899478.7348.349.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070613100334.635756997@chello.nl>
	 <617E1C2C70743745A92448908E030B2A01AF860A@scsmsx411.amr.corp.intel.com>
	 <65dd6fd50706132323i9c760f4m6e23687914d0c46e@mail.gmail.com>
	 <1181810319.7348.345.camel@twins>
	 <65dd6fd50706141358i39bba32aq139766c8a1a3de2b@mail.gmail.com>
	 <1181899478.7348.349.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On 6/15/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> On Thu, 2007-06-14 at 13:58 -0700, Ollie Wild wrote:
>
> >   A good heuristic, though, might be to limit
> > argument size to a percentage (say 25%) of maximum stack size and
> > validate this inside copy_strings().
>
> This seems to do:

Looks good.

Ollie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
