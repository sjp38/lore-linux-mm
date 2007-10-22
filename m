Received: by rv-out-0910.google.com with SMTP id l15so1038637rvb
        for <linux-mm@kvack.org>; Mon, 22 Oct 2007 13:48:37 -0700 (PDT)
Message-ID: <84144f020710221348x297795c0qda61046ec69a7178@mail.gmail.com>
Date: Mon, 22 Oct 2007 23:48:37 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland
In-Reply-To: <Pine.LNX.4.64.0710222101420.23513@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0710142049000.13119@sbz-30.cs.Helsinki.FI>
	 <200710142232.l9EMW8kK029572@agora.fsl.cs.sunysb.edu>
	 <84144f020710150447o94b1babo8b6e6a647828465f@mail.gmail.com>
	 <Pine.LNX.4.64.0710222101420.23513@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Erez Zadok <ezk@cs.sunysb.edu>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org, neilb@suse.de
List-ID: <linux-mm.kvack.org>

Hi Hugh,

On Mon, 15 Oct 2007, Pekka Enberg wrote:
> > I wonder whether _not setting_ BDI_CAP_NO_WRITEBACK implies that
> > ->writepage() will never return AOP_WRITEPAGE_ACTIVATE for
> > !wbc->for_reclaim case which would explain why we haven't hit this bug
> > before. Hugh, Andrew?

On 10/22/07, Hugh Dickins <hugh@veritas.com> wrote:
> Only ramdisk and shmem have been returning AOP_WRITEPAGE_ACTIVATE.
> Both of those set BDI_CAP_NO_WRITEBACK.  ramdisk never returned it
> if !wbc->for_reclaim.  I contend that shmem shouldn't either: it's
> a special code to get the LRU rotation right, not useful elsewhere.
> Though Documentation/filesystems/vfs.txt does imply wider use.
>
> I think this is where people use the phrase "go figure" ;)

Heh. As far as I can tell, the implication of "wider use" was added by
Neil in commit "341546f5ad6fce584531f744853a5807a140f2a9 Update some
VFS documentation", so perhaps he might know? Neil?

                               Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
