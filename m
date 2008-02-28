Received: by wf-out-1314.google.com with SMTP id 25so7806100wfc.11
        for <linux-mm@kvack.org>; Thu, 28 Feb 2008 01:50:36 -0800 (PST)
Message-ID: <e2e108260802280150j62c8269ere4aafca76970a259@mail.gmail.com>
Date: Thu, 28 Feb 2008 10:50:36 +0100
From: "Bart Van Assche" <bart.vanassche@gmail.com>
Subject: Re: SMP-related kernel memory leak
In-Reply-To: <Pine.LNX.4.64.0802271139090.1790@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <e2e108260802190300k5b0f60f6tbb4f54997caf4c4e@mail.gmail.com>
	 <6101e8c40802210821w626bc831uaf4c3f66fb097094@mail.gmail.com>
	 <6101e8c40802210825v534f0ce3wf80a18ebd6dee925@mail.gmail.com>
	 <47BDEFB4.1010106@zytor.com>
	 <6101e8c40802220844h2553051bw38154dbad91de1e3@mail.gmail.com>
	 <47BEFD5D.402@zytor.com>
	 <6101e8c40802221512t295566bey5a8f1c21b8751480@mail.gmail.com>
	 <47BF5932.9040200@zytor.com>
	 <e2e108260802230008y4179970dw6581c1a361eac280@mail.gmail.com>
	 <Pine.LNX.4.64.0802271139090.1790@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Oliver Pinter <oliver.pntr@gmail.com>, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2008 at 8:40 PM, Christoph Lameter <clameter@sgi.com> wrote:
> On Sat, 23 Feb 2008, Bart Van Assche wrote:
>
>  > The patch referenced above modifies a single file:
>  > include/asm-generic/tlb.h. I had a look at the git history of Linus'
>  > 2.6.24 tree, and noticed that the cited patch was applied on December
>  > 18, 2007 to Linus' tree by Christoph Lameter. Two weeks later, on
>  > December 27, the change was reverted by Christoph. Christoph, can you
>  > provide us some more background information about why the patch was
>  > reverted ?
>
>  It did not fix the problem that was reported. Commit
>  96990a4ae979df9e235d01097d6175759331e88c took its place.

I did a grep through the kernel changelogs for this commit:

$ grep 96990a4ae979df9e235d01097d6175759331e88c *
ChangeLog-2.6.22.19:    patch 96990a4ae979df9e235d01097d6175759331e88c
in mainline.
ChangeLog-2.6.23.15:    patch 96990a4ae979df9e235d01097d6175759331e88c
in mainline.
ChangeLog-2.6.24:commit 96990a4ae979df9e235d01097d6175759331e88c

Or: this commit should have been included in kernel 2.6.24. But the
PAE memory leak I observed still occurs with 2.6.24.2. So the question
remains: is there already a fix available for the problem I observed ?

Bart Van Assche.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
