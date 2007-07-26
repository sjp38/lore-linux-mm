Received: by nz-out-0506.google.com with SMTP id s1so616546nze
        for <linux-mm@kvack.org>; Thu, 26 Jul 2007 15:30:15 -0700 (PDT)
Message-ID: <b14e81f00707261530i6ebe73derdebe52a0aee687a8@mail.gmail.com>
Date: Thu, 26 Jul 2007 18:30:14 -0400
From: "Michael Chang" <thenewme91@gmail.com>
Subject: Re: -mm merge plans for 2.6.23
In-Reply-To: <b21f8390707251815o767590acrf6a6c4d7290a26a8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	 <46A58B49.3050508@yahoo.com.au>
	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	 <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com>
	 <Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm>
	 <46A6DFFD.9030202@gmail.com>
	 <2c0942db0707250902v58e23d52v434bde82ba28f119@mail.gmail.com>
	 <b21f8390707251815o767590acrf6a6c4d7290a26a8@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Hawkins <darthmdh@gmail.com>
Cc: Ray Lee <ray-lk@madrabbit.org>, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 7/25/07, Matthew Hawkins <darthmdh@gmail.com> wrote:
> On 7/26/07, Ray Lee <ray-lk@madrabbit.org> wrote:
> > I'd just like updatedb to amortize its work better. If we had some way
> > to track all filesystem events, updatedb could keep a live and
> > accurate index on the filesystem. And this isn't just updatedb that
> > wants that, beagle and tracker et al also want to know filesystem
> > events so that they can index the documents themselves as well as the
> > metadata. And if they do it live, that spreads the cost out, including
> > the VM pressure.
>
> We already have this, its called inotify (and if I'm not mistaken,
> beagle already uses it).  Several years ago when it was still a little
> flakey patch, I built a custom filesystem indexer into an enterprise
> search engine using it (I needed to pull apart Unix mbox files).  The
> only trouble of course is the action is triggered immediately, which
> may not always be ideal (but that's a userspace problem)
>

With all this discussion about updatedb and locate and such, I thought
I'd do a Google search, (considering I've never heard of locate before
but I've seen updatedb here and there in ps lists) and I found this:

http://www.linux.com/articles/114029

That page mentions something called "rlocate", which seems to provide
some sort of almost-real-time mechanism, although the method it does
so bothers me -- it uses a 2.6 kernel module AND a userspace daemon.
And from what I can tell, there's no indication that this almost
"real-time" (--I see mentions of a 2 second lag--) system
replaces/eliminates updatedb in any way, shape, or form.

http://rlocate.sourceforge.net/ - Project "Web Site"
http://sourceforge.net/projects/rlocate/ - Source Forge Project Summary

The last release also appears a bit dated on sourceforge... release
0.4.0 on 2006-01-15.

Just thought I'd mention it.


-- 
Michael Chang

Please avoid sending me Word or PowerPoint attachments. Send me ODT,
RTF, or HTML instead.
See http://www.gnu.org/philosophy/no-word-attachments.html
Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
