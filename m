Subject: Re: manual page migration, revisited...
From: Nigel Cunningham <ncunningham@linuxmail.org>
Reply-To: ncunningham@linuxmail.org
In-Reply-To: <418DAB45.7040907@sgi.com>
References: <418C03CD.2080501@sgi.com>
	 <1099695742.4507.114.camel@desktop.cunninghams>  <418DAB45.7040907@sgi.com>
Content-Type: text/plain
Message-Id: <1099861888.5461.2.camel@desktop.cunninghams>
Mime-Version: 1.0
Date: Mon, 08 Nov 2004 08:11:28 +1100
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi.

On Sun, 2004-11-07 at 15:57, Ray Bryant wrote:
> I think that having the resumed processes show up with a different pid than 
> they had before is show-stopper.  In a multiprocess parallel program, we have
> no idea whether the program itself has saved way pid's and is using them to
> send signals or whatnot.  So I don't think there is a user space-only solution
> that will solve this problem for us, but it an interesting alternative to
> the kernel-only solutions I've been contemplating.  There is probably some
> intermediate ground there which holds the real solution.

I agree; it should be pretty trivial to add a patch to check that a
given PID is not in use, allocate it and get the resumed program known
by that PID. I won't offer to do it, though. I've got enough work at the
moment :>

Nigel
-- 
Nigel Cunningham
Pastoral Worker
Christian Reformed Church of Tuggeranong
PO Box 1004, Tuggeranong, ACT 2901

You see, at just the right time, when we were still powerless, Christ
died for the ungodly.		-- Romans 5:6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
