Subject: Re: BUG_ON in remap_pte_range: Why?
From: Ed L Cashin <ecashin@uga.edu>
Date: Wed, 21 May 2003 00:20:32 -0400
In-Reply-To: <20030520202728.42626.qmail@web12308.mail.yahoo.com> (Ravi's
 message of "Tue, 20 May 2003 13:27:28 -0700 (PDT)")
Message-ID: <873cj93p7z.fsf@cs.uga.edu>
References: <20030520202728.42626.qmail@web12308.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravi <kravi26@yahoo.com>
Cc: linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

Ravi <kravi26@yahoo.com> writes:

> Hi,
>
> I am looking at the latest mm/memory.c on Bitkeeper.
> The comment for remap_pte_range() says "maps a range of 
> physical memory into the requested pages. the old mappings
> are removed". But the code has this check:
>
> BUG_ON(!pte_none(*pte));
>
> Why is it a bug to have a valid PTE when remap_pte_range()
> is called? The 2.4 version of this fucntion cleared the
> old PTE using ptep_get_and_clear() and then installed
> a new one. Why was this changed?

It used to be a call to forget_pte, and, as Flavio Bruno Leitner
pointed out, wli changed it last year:

  http://www.ussg.iu.edu/hypermail/linux/kernel/0206.0/0053.html

... making forget_pte into a macro, which has since been completely
inlined.  The comment that used to be above the macro was this:

  bug check to be sure pte's are unmapped when no longer used 


-- 
--Ed L Cashin     PGP public key: http://noserose.net/e/pgp/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
