Received: from mail.lu.unisi.ch ([195.176.178.40] verified)
  by ti-edu.ch (CommuniGate Pro SMTP 5.1.12)
  with ESMTP id 22472162 for linux-mm@kvack.org; Wed, 10 Oct 2007 06:42:19 +0200
Message-ID: <470C5824.7030100@lu.unisi.ch>
Date: Wed, 10 Oct 2007 06:42:12 +0200
From: Paolo Bonzini <paolo.bonzini@lu.unisi.ch>
Reply-To: bonzini@gnu.org
MIME-Version: 1.0
Subject: Re: [Bug 9138] New: kernel overwrites MAP_PRIVATE mmap
References: <bug-9138-27@http.bugzilla.kernel.org/> <20071009083913.212fb3e3.akpm@linux-foundation.org> <470BA58F.8050907@lu.unisi.ch> <Pine.LNX.4.64.0710091711450.30785@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0710091711450.30785@blonde.wat.veritas.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: bonzini@gnu.org, Andrew Morton <akpm@linux-foundation.org>, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> It is standard behaviour that truncating the inode on which an mmap
> was done will generate SIGBUS on access to pages of the mmap beyond
> the new end of file.  Easier to understand when MAP_SHARED, but even
> when MAP_PRIVATE, and even when private pages have already been
> C-O-Wed from the file.

I would have expected MAP_PRIVATE to establish a snapshot of the file, 
as it appears to do on BSDs.  I find it hard to believe that code in the 
wild wants this behavior for MAP_PRIVATE (on the other hand, it is 
clearly the right thing for MAP_SHARED).

> Might it have been a different version of Smalltalk which was tested
> with the 2.6.8 kernel, a version which didn't cause this to happen?

Two weeks ago it started failing on x86-64 after a kernel update but 
still worked on i686; then, yesterday it also started failing on i686 
(guess what, after another kernel update).  It might well be that the 
bug was latent in 2.6.8 and was uncovered by another mmap-related change 
in the kernel, or something like that.

I can work around it by unlink+open; though it will break hard links, 
that's not a big deal.

Thanks for the explanation.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
