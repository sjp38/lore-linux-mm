Date: Mon, 14 Apr 2008 16:09:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0 of 9] mmu notifier #v12
In-Reply-To: <patchbomb.1207669443@duo.random>
Message-ID: <Pine.LNX.4.64.0804141559410.11036@schroedinger.engr.sgi.com>
References: <patchbomb.1207669443@duo.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Apr 2008, Andrea Arcangeli wrote:

> The difference with #v11 is a different implementation of mm_lock that
> guarantees handling signals in O(N). It's also more lowlatency friendly. 

Ok. So the rest of the issues remains unaddressed? I am glad that we 
finally settled on the locking. But now I will have to clean this up, 
address the remaining issues, sequence the patches right, provide docs, 
handle the merging issue etc etc? I have seen no detailed review of my 
patches that you include here.

We are going down the same road as we had to go with the OOM patches where 
David Rientjes and me had to deal with the issues you raised?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
