Received: by uproxy.gmail.com with SMTP id k40so195972ugc
        for <linux-mm@kvack.org>; Tue, 17 Jan 2006 00:29:15 -0800 (PST)
Message-ID: <aec7e5c30601170029if0ed895le2c18b26eb7c6a42@mail.gmail.com>
Date: Tue, 17 Jan 2006 17:29:15 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: Race in new page migration code?
In-Reply-To: <Pine.LNX.4.62.0601152251550.17034@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20060114155517.GA30543@wotan.suse.de>
	 <Pine.LNX.4.62.0601140955340.11378@schroedinger.engr.sgi.com>
	 <20060114181949.GA27382@wotan.suse.de>
	 <Pine.LNX.4.62.0601141040400.11601@schroedinger.engr.sgi.com>
	 <43C9DD98.5000506@yahoo.com.au>
	 <Pine.LNX.4.62.0601152251550.17034@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 1/16/06, Christoph Lameter <clameter@engr.sgi.com> wrote:
> On Sun, 15 Jan 2006, Nick Piggin wrote:
>
> > OK (either way is fine), but you should still drop the __isolate_lru_page
> > nonsense and revert it like my patch does.
>
> Ok with me. Magnus: You needed the __isolate_lru_page for some other
> purpose. Is that still the case?

It made sense to have it broken out when it was used twice within
vmscan.c, but now when the patch changed a lot and the function is
used only once I guess the best thing is to inline it as Nick
suggested. I will re-add it myself later on when I need it. Thanks.

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
