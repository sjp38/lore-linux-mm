Date: Tue, 1 May 2001 10:36:31 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Hopefully a simple question on /proc/pid/mem
Message-ID: <20010501103631.J26638@redhat.com>
References: <Pine.GSO.4.21.0104301457010.5737-100000@weyl.math.psu.edu> <Pine.LNX.3.96.1010430145934.30664D-100000@kanga.kvack.org> <20010430225802.H26638@redhat.com> <m166flhnvy.fsf@frodo.biederman.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m166flhnvy.fsf@frodo.biederman.org>; from ebiederm@xmission.com on Mon, Apr 30, 2001 at 07:13:53PM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Alexander Viro <viro@math.psu.edu>, Richard F Weber <rfweber@link.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Apr 30, 2001 at 07:13:53PM -0600, Eric W. Biederman wrote:

> > Hint: think about what happens if you make a shared mapping of a
> > private proc/*/mem region... 
> 
> Now that we have reusable swap cache pages we could make it work
> correctly, except for the case of the first write a private mapping of
> file.    Not that we would want to...

Think about fork.  If a parent forks and then touches a private page
before the child does, it's the parent which gets a new page.  The
supposed shared mmap of the parent now points to the child's page, not
the parent's.  COW basically just can't do the right thing if a page
is both shared and private at the same time.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
