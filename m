Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: page_launder() bug
Date: Mon, 7 May 2001 15:49:15 +0200
References: <Pine.LNX.4.33.0105070823060.24073-100000@svea.tellus>
In-Reply-To: <Pine.LNX.4.33.0105070823060.24073-100000@svea.tellus>
MIME-Version: 1.0
Message-Id: <01050715491500.08789@starship>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tobias Ringstrom <tori@tellus.mine.nu>, "David S. Miller" <davem@redhat.com>
Cc: Jonathan Morton <chromi@cyberspace.org>, BERECZ Szabolcs <szabi@inf.elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 07 May 2001 08:26, Tobias Ringstrom wrote:
> On Sun, 6 May 2001, David S. Miller wrote:
> > It is the most straightforward way to make a '1' or '0'
> > integer from the NULL state of a pointer.
>
> But is it really specified in the C "standards" to be exctly zero or
> one, and not zero and non-zero?

Yes, and if we did not have this stupid situation where the C language 
standard is not freely available online then you would not have had to 
ask.</rant>

> IMHO, the ?: construct is way more readable and reliable.

There is no difference in reliability.  Readability is a matter of 
opinion - my opinion is that they are equally readable.  To its credit, 
gcc produces the same ia32 code in either case:

	int foo = 999;
	return 1 + !!foo;

<main+6>:	movl   $0x3e7,0xfffffffc(%ebp)
<main+13>:	cmpl   $0x0,0xfffffffc(%ebp)
<main+17>:	je     0x80483e0 <main+32>
<main+19>:	mov    $0x2,%eax
<main+24>:	jmp    0x80483e5 <main+37>
<main+26>:	lea    0x0(%esi),%esi
<main+32>:	mov    $0x1,%eax
<main+37>:	mov    %eax,%eax

	int foo = 999;
	return foo? 2: 1;

<main+6>:	movl   $0x3e7,0xfffffffc(%ebp)
<main+13>:	cmpl   $0x0,0xfffffffc(%ebp)
<main+17>:	je     0x80483e0 <main+32>
<main+19>:	mov    $0x2,%eax
<main+24>:	jmp    0x80483e5 <main+37>
<main+26>:	lea    0x0(%esi),%esi
<main+32>:	mov    $0x1,%eax
<main+37>:	mov    %eax,%eax

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
