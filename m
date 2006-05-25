Date: Thu, 25 May 2006 10:03:32 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [PATCH 1/3] mm: tracking shared dirty pages
In-Reply-To: <1148576422.10561.80.camel@lappy>
Message-ID: <Pine.LNX.4.64.0605251001080.30649@graphe.net>
References: <20060525135534.20941.91650.sendpatchset@lappy>
 <20060525135555.20941.36612.sendpatchset@lappy>
 <Pine.LNX.4.64.0605250856020.23726@schroedinger.engr.sgi.com>
 <1148576422.10561.80.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Thu, 25 May 2006, Peter Zijlstra wrote:

> On Thu, 2006-05-25 at 09:21 -0700, Christoph Lameter wrote:
> > On Thu, 25 May 2006, Peter Zijlstra wrote:
> > 
> > > @@ -1446,12 +1447,13 @@ static int do_wp_page(struct mm_struct *
> > >  
> > > -	if (unlikely(vma->vm_flags & VM_SHARED)) {
> > > +	if (vma->vm_flags & VM_SHARED) {
> > 
> > You add this unlikely later again it seems. Why remove in the first place?
> 
> I'm not sure I follow you, are you suggesting that we'll find the
> condition to be unlikely still, even with most of the shared mappings
> trapping this branch?

No, I just saw the opposite in a later patch. It was the -1 patch that 
does

+       if (unlikely(vma->vm_flags & VM_SHARED)) {

but thats a different context?
\

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
