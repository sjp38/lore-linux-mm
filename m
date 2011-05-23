Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D6DB96B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 19:34:04 -0400 (EDT)
Received: from mail-vw0-f41.google.com (mail-vw0-f41.google.com [209.85.212.41])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p4NNXXv5028059
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Mon, 23 May 2011 16:33:33 -0700
Received: by vws4 with SMTP id 4so6559315vws.14
        for <linux-mm@kvack.org>; Mon, 23 May 2011 16:33:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DDAEC68.30803@zytor.com>
References: <BANLkTi=PLuZhx1=rCfOtg=aOTuC1UbuPYg@mail.gmail.com>
 <20110523192056.GC23629@elte.hu> <BANLkTikdgM+kSvaEYuQkgCYJZELnvwfetg@mail.gmail.com>
 <20110523231721.GM10009@thunk.org> <4DDAEC68.30803@zytor.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 23 May 2011 16:33:12 -0700
Message-ID: <BANLkTikGfVSAMY2a2yiXaNpvBVvF8YdMEA@mail.gmail.com>
Subject: Re: (Short?) merge window reminder
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ted Ts'o <tytso@mit.edu>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, DRI <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@suse.de>

Another advantage of switching numbering models (ie 3.0 instead of
2.8.x) would be that it would also make the "odd numbers are also
numbers" transition much more natural.

Because of our historical even/odd model, I wouldn't do a 2.7.x -
there's just too much history of 2.1, 2.3, 2.5 being development
trees. But if I do 3.0, then I'd be chucking that whole thing out the
window, and the next release would be 3.1, 3.2, etc..

And then in another few years (probably before getting close to 3.40,
so I'm not going to make a big deal of 3 = "third decade"), I'd just
do 4.0 etc.

Because all our releases are supposed to be stable releases these
days, and if we get rid of one level of numbering, I feel perfectly
fine with getting rid of the even/odd history too.

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
