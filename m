Message-ID: <45461BC7.5050609@shadowen.org>
Date: Mon, 30 Oct 2006 15:35:35 +0000
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: Slab panic on 2.6.19-rc3-git5 (-git4 was OK)
References: <454442DC.9050703@google.com> <20061029000513.de5af713.akpm@osdl.org> <4544E92C.8000103@shadowen.org> <4545325D.8080905@mbligh.org> <Pine.LNX.4.64.0610291718481.25218@g5.osdl.org>
In-Reply-To: <Pine.LNX.4.64.0610291718481.25218@g5.osdl.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, "Martin J. Bligh" <mbligh@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Sun, 29 Oct 2006, Martin J. Bligh wrote:
>> Seems like that doesn't fix it, I'm afraid.
> 
> Does the one in the current -git tree? It's commit 
> 5211e6e6c671f0d4b1e1a1023384d20227d8ee65, as below..
> 
> 		Linus

Test results are back on the version of the slab panic fix which Linus'
has committed in his tree.  This change on top of 2.6.19-rc3-git5 is
good.  2.6.19-rc3-git6 is also showing good on this machine.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
