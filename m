Date: Fri, 1 Feb 2008 02:19:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] NULL pointer check for vma->vm_mm
Message-Id: <20080201021917.5db3448d.akpm@linux-foundation.org>
In-Reply-To: <3fd7d7a70802010024q22b4d179mf56e6d4b60e4f574@mail.gmail.com>
References: <3fd7d7a70801312339p2a142096p83ed286c81379728@mail.gmail.com>
	<20080131235544.346b938a.akpm@linux-foundation.org>
	<3fd7d7a70802010024q22b4d179mf56e6d4b60e4f574@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kenichi Okuyama <kenichi.okuyama@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 Feb 2008 17:24:17 +0900 "Kenichi Okuyama" <kenichi.okuyama@gmail.com> wrote:

> First of all, thank you for looking at the patch.
> 
> I do agree that if mm is NULL, system will call Oops anyway.
> However, since it's oops, it does not stop the system, nor call kdump.

That would be a huge bug in kdump?  Surely it dumps when the kernel oopses?

> By calling BUG_ON(), it'll gives us chance of calling kdump at the first chance.
> 
> Since this is very rare to happen, I thought we should capture the incident
> whenever possible. On other hand, because BUG_ON macro is very light,
> I thought this will not harm any performance...
> 
> Forgive me in advance if I was wrong.
> I still think checking mm with BUG_ON here is better than counting on Oops.

But there are probably a million potential NULL-pointer dereferences in the 
kernel.  Why single out this one?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
