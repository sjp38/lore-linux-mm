Received: by wx-out-0506.google.com with SMTP id h31so1255702wxd.11
        for <linux-mm@kvack.org>; Fri, 01 Feb 2008 09:39:23 -0800 (PST)
Message-ID: <3fd7d7a70802010939q67770628r47ca8a23fb26ca1d@mail.gmail.com>
Date: Sat, 2 Feb 2008 02:39:23 +0900
From: "Kenichi Okuyama" <kenichi.okuyama@gmail.com>
Subject: Re: [patch] NULL pointer check for vma->vm_mm
In-Reply-To: <20080201021917.5db3448d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <3fd7d7a70801312339p2a142096p83ed286c81379728@mail.gmail.com>
	 <20080131235544.346b938a.akpm@linux-foundation.org>
	 <3fd7d7a70802010024q22b4d179mf56e6d4b60e4f574@mail.gmail.com>
	 <20080201021917.5db3448d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dear Andrew,
Sorry that it took very long before I could reply.

2008/2/1, Andrew Morton <akpm@linux-foundation.org>:
> On Fri, 1 Feb 2008 17:24:17 +0900 "Kenichi Okuyama" <kenichi.okuyama@gmail.com> wrote:
>
> > First of all, thank you for looking at the patch.
> >
> > I do agree that if mm is NULL, system will call Oops anyway.
> However, since it's oops, it does not stop the system, nor call kdump.
>
> That would be a huge bug in kdump?  Surely it dumps when the kernel oopses?

I'm sorry.
Oops did dump on my home pc. But it didn't on my office pc.
I'll take back the patch, and check what I've done wrong at office.


> But there are probably a million potential NULL-pointer dereferences in the
> kernel.  Why single out this one?

I was interested in "Bad swap file entry" problem.

I expereiced this myself. After (quite a lot of ) "Bad swap file
entry" error log from kernel, it Oopsed three times, then kernel was
dead ( It's almost three years from now, so this was without kdump ).

I did find that three Oops happened inside page_referenced() function,
and that it was due to NULL pointer. In 2.6.24, it was only this "mm"
and one more in page_referenced_file() that did not have NULL pointer
check.

So I was really thinking about two more patches. One for "mappers"
NULL pointer check, and other one is to add msr printout when Oops or
Pank happens , to make sure that when Oops or Paniced, still my PC is
not broken.


I needed the evidence so that I don't have to worry about
broken Memory, nor broken Cache.
and I think we still do not have MSRs dumped out as
part of kdump..
# Am I wrong again??
-- 
Kenichi Okuyama
URL: http://www.dd.iij4u.or.jp/~okuyamak/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
