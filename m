Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f173.google.com (mail-ea0-f173.google.com [209.85.215.173])
	by kanga.kvack.org (Postfix) with ESMTP id A47E16B0036
	for <linux-mm@kvack.org>; Sun, 22 Dec 2013 16:38:48 -0500 (EST)
Received: by mail-ea0-f173.google.com with SMTP id o10so2027036eaj.32
        for <linux-mm@kvack.org>; Sun, 22 Dec 2013 13:38:48 -0800 (PST)
Date: Sun, 22 Dec 2013 16:30:56 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCHes - aio / migrate page, please review] Re: bad page state
 in 3.13-rc4
Message-ID: <20131222213056.GA22579@redhat.com>
References: <20131219182920.GG30640@kvack.org>
 <CA+55aFzCo_r7ZGHk+zqUjmCW2w7-7z9oxEJjhR66tZ4qZPxnvw@mail.gmail.com>
 <20131219192621.GA9228@kvack.org>
 <CA+55aFz=tEkVAx9VndtCXApDxcw+5T-BxMsVuXp+vMSb05f8Aw@mail.gmail.com>
 <20131219195352.GB9228@kvack.org>
 <20131219202416.GA14519@redhat.com>
 <20131219233854.GD10905@kvack.org>
 <20131220010042.GA32112@redhat.com>
 <20131221230644.GB29743@kvack.org>
 <CA+55aFx3dLwLdo90g0xo_t-iv+8k6TBy+=wQfd1UX3YbDFRFhw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFx3dLwLdo90g0xo_t-iv+8k6TBy+=wQfd1UX3YbDFRFhw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Benjamin LaHaise <bcrl@kvack.org>, Kent Overstreet <kmo@daterainc.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@gentwo.org>, Al Viro <viro@zeniv.linux.org.uk>

On Sun, Dec 22, 2013 at 11:09:34AM -0800, Linus Torvalds wrote:
 > On Sat, Dec 21, 2013 at 3:06 PM, Benjamin LaHaise <bcrl@kvack.org> wrote:
 > >
 > > Linus, feel free to add my Signed-off-by: to your sanitization of
 > > aio_setup_ring() as well, as it works okay in my testing.
 > 
 > Nobody commented on your request for comments, so I applied my patch
 > and pulled your branch, because I'm going to do -rc5 in a few and at
 > least we want this to get testing.
 > 
 > Dave, let's hope that the leak fixes and reference count fixes solve
 > your problem.

Yeah, I'm not really going to have time to run tests again until after
the holidays. I'll shout when I get back if things still don't look right.
(or more likely, if I find something else ;-)

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
