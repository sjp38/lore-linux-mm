Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f53.google.com (mail-qe0-f53.google.com [209.85.128.53])
	by kanga.kvack.org (Postfix) with ESMTP id 49BDD6B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 16:08:06 -0500 (EST)
Received: by mail-qe0-f53.google.com with SMTP id nc12so1543190qeb.40
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 13:08:06 -0800 (PST)
Date: Thu, 19 Dec 2013 15:24:16 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: bad page state in 3.13-rc4
Message-ID: <20131219202416.GA14519@redhat.com>
References: <20131219040738.GA10316@redhat.com>
 <CA+55aFwweoGs3eGWXFULcqnbRbpDhpj2qrefXB5OpQOiWW8wYA@mail.gmail.com>
 <20131219155313.GA25771@redhat.com>
 <CA+55aFyoXCDNfHb+r5b=CgKQLPA1wrU_Tmh4ROZNEt5TPjpODA@mail.gmail.com>
 <20131219181134.GC25385@kmo-pixel>
 <20131219182920.GG30640@kvack.org>
 <CA+55aFzCo_r7ZGHk+zqUjmCW2w7-7z9oxEJjhR66tZ4qZPxnvw@mail.gmail.com>
 <20131219192621.GA9228@kvack.org>
 <CA+55aFz=tEkVAx9VndtCXApDxcw+5T-BxMsVuXp+vMSb05f8Aw@mail.gmail.com>
 <20131219195352.GB9228@kvack.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131219195352.GB9228@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Kent Overstreet <kmo@daterainc.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@gentwo.org>, Al Viro <viro@zeniv.linux.org.uk>

On Thu, Dec 19, 2013 at 02:53:52PM -0500, Benjamin LaHaise wrote:

 > is populated into the page tables).  The only place I can see things going 
 > off the rails is if the get_user_pages() call fails.  It's possible trinity 
 > could be arranging things so that the get_user_pages() call is failing 
 > somehow.  Also, if it were a double free of a page, we should at least get 
 > a VM_BUG() occuring when the page's count is 0.
 > 
 > Dave -- do you have CONFIG_DEBUG_VM on in your test rig?

Yes. Note the original trace in this thread was a VM_BUG_ON(atomic_read(&page->_count) <= 0);

Right after these crashes btw, the box locks up solid. So bad that traces don't
always make it over usb-serial. Annoying.

	Dave


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
