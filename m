Date: Mon, 1 Dec 2003 04:02:52 +0100
From: Guillaume Morin <guillaume@morinfr.org>
Subject: Re: [PATCH] Clear dirty bits etc on compound frees
Message-ID: <20031201030252.GC18393@oyster.morinfr.org>
References: <22420000.1069877625@[10.10.2.4]> <20031126122036.6389c773.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20031126122036.6389c773.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dans un message du 26 Nov a 12:20, Andrew Morton ecrivait :
> hmm.  How did the dirty bit get itself set?

Pages in the cluster are mmaped via the nopage method as decribed in
Linux Device Drivers : http://www.xml.com/ldd/chapter/book/ch13.html#t2
in section "Remapping RAM". When the userspace program writes on a page,
it gets the dirty bit.

-- 
Guillaume Morin <guillaume@morinfr.org>

   I'm unclean, a libertine, every time you vent your spleen, I seem to lose
    the power of speech, you're slipping slowly from my reach, you grow me
        like an evergreen, you've never seen me lonely at all. (Placebo)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
