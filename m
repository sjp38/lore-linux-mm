Date: Tue, 30 Jul 2002 12:38:52 -0400
Subject: Re: [RFC] start_aggressive_readahead
Content-Type: text/plain; charset=US-ASCII; format=flowed
Mime-Version: 1.0 (Apple Message framework v482)
From: Scott Kaplan <sfkaplan@cs.amherst.edu>
In-Reply-To: <644994853.1028020916@[10.10.2.3]>
Message-Id: <D4FAAB57-A3DA-11D6-9922-000393829FA4@cs.amherst.edu>
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: Andrew Morton <akpm@zip.com.au>, Rik van Riel <riel@conectiva.com.br>, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Tuesday, July 30, 2002, at 12:21 PM, Martin J. Bligh wrote:

> Thus I'd contend that either growing or shrinking in straight
> response to just a hit/miss rate is not correct. We need to actually
> look at the access pattern of the application, surely?

I agree.  I probably should have made it clear that what I was suggesting 
wasn't the right way to go about it, but rather an argument against the 
heuristics that seemed backwards to me.

The causes for misses are necessarily as clear cut as you mentioned, as 
there are a lot of behaviors that are neither fully random nor fully 
sequential.  So, while it is ideal to have some foresight before resizing 
the window -- some calculation that determines whether or not growth will 
help or shrinkage will hurt -- it will require the VM system to gather hit 
distributions.  I'm trying to make that happen right now, although for all 
VM pages, and not for the specific purpose of read-ahead calculations.  
However, the paper for which I gave a pointer (in a shameless act of self 
promotion) proposes exactly that:  Keeping reference distributions for 
read-ahead and non-read-ahead pages, and then balancing the two against 
each other in an attempt to determine what the best read-ahead window size 
would be given recent reference behavior.

There may be simpler, kruftier, and/or more effective versions of what I 
proposed, but what you said above is, I think, the right idea.

Scott
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (Darwin)
Comment: For info see http://www.gnupg.org

iD8DBQE9RsEf8eFdWQtoOmgRAp+vAJoCF6mUgAI42x6Bac4A2/u+7oZXIwCdHVqZ
AQCPlqTF+84udI5xSWqYWas=
=swZ6
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
