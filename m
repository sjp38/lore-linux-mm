Date: Tue, 17 Aug 1999 00:03:56 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
In-Reply-To: <199908170650.XAA95856@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.9908170003290.1048-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: andrea@suse.de, alan@lxorguk.ukuu.org.uk, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 16 Aug 1999, Kanoj Sarcar wrote:
> 
> Btw, my vote goes for finding and fixing all such driver code, instead 
> of just breaking them for bigmem machines.

The code in question cannot be "fixed". It's doing something wrong in the
first place, 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
