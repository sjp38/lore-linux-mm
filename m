Content-Type: text/plain;
  charset="iso-8859-1"
From: Scott F. Kaplan <sfkaplan@cs.amherst.edu>
Subject: Re: VM tuning through fault trace gathering [with actual code]
Date: Tue, 26 Jun 2001 10:02:26 -0400
References: <Pine.LNX.4.21.0106251456130.7419-100000@imladris.rielhome.conectiva> <m28zigi7m4.fsf@boreas.yi.org.>
In-Reply-To: <m28zigi7m4.fsf@boreas.yi.org.>
MIME-Version: 1.0
Message-Id: <01062610022607.01124@spigot>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

John Fremlin <vii@users.sourceforge.net> wrote:
> Rik van Riel <riel@conectiva.com.br> writes:
> > Sounds like a cool idea.  One thing you should keep in mind though
> > is to gather traces of the WHOLE SYSTEM and not of individual
> > applications.

Not to look a gift horse in the mouth, but the ability to trace selectively 
either the whole system OR an individual application would be useful.  
Certainly whole system traces would be new, as individual process traces can 
be gathered with other tools (although I don't know of one available on Linux 
- -- I'm stuck using ATOM under Alpha/Tru64.)

> In the current patch all pagefaults are recorded from all sources. I'd
> like to be able to catch read(2) and write(2) (buffer cache stuff) as
> well but I don't know how . . . .

Also a great idea.  Someone who works on the filesystem end of the kernel 
should be able to add support for this kind of thing without much trouble, 
don't you think?

> Of course! It is important not to regard each thread group as an
> independent entity IMHO (had a big old argument about this).

Yes, I was the other side of that argument! :-)  I'll still contend that, 
tracking references for each process is better than tracking it only for the 
whole system, and tracking references for each thread might be better still.  
When you track references from the whole-system view alone, pathological 
reference behavior of one process gets mixed in with other processes, making 
it impossible to identify that the one process should have its memory managed 
in a manner different from the others.  Grouping together behaviors just 
smooths their features.  Separating them offers an opportunity to identify 
anomolies, and anomolies are opportunities for better memory management.

Scott
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.4 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE7OJX18eFdWQtoOmgRAmniAKCTFGVJmgMOXJWiHfA+UxVUiT37zQCfZywy
bRYZKRymeXfjhh6wX2SZb6I=
=5TTZ
-----END PGP SIGNATURE-----
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
