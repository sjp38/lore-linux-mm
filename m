Subject: Re: 2.5.70-mm6
From: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
In-Reply-To: <64000000.1055189666@flay>
References: <20030607151440.6982d8c6.akpm@digeo.com>
	 <Pine.LNX.4.51.0306091943580.23392@dns.toxicfilms.tv>
	 <46580000.1055180345@flay>
	 <Pine.LNX.4.51.0306092017390.25458@dns.toxicfilms.tv>
	 <51250000.1055184690@flay>
	 <1055189322.600.1.camel@teapot.felipe-alfaro.com>
	 <64000000.1055189666@flay>
Content-Type: text/plain
Message-Id: <1055192945.600.3.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Date: 09 Jun 2003 23:09:05 +0200
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Maciej Soltysiak <solt@dns.toxicfilms.tv>, Andrew Morton <akpm@digeo.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2003-06-09 at 22:14, Martin J. Bligh wrote:
> --On Monday, June 09, 2003 22:08:42 +0200 Felipe Alfaro Solana <felipe_alfaro@linuxmail.org> wrote:
> 
> > On Mon, 2003-06-09 at 20:51, Martin J. Bligh wrote:
> >> >> If you don't nice the hell out of X, does it work OK?
> >> > No.
> >> > 
> >> > The way I reproduce the sound skips:
> >> > run xmms, run evolution, compose a mail with gpg.
> >> > on mm6 the gpg part stops the sound for a few seconds. (with X -10 and 0)
> >> > on mm5 xmms plays without stops. (with X -10)
> >> 
> >> Does this (from Ingo?) do anything useful to it?
> > 
> > I can confirm that 2.5.70-mm6 with Ingo's patch and HZ set back to 1000
> > is nearly perfect (it still takes some seconds for the scheduler to
> > adjust dynamic priorities).
> 
> OK ... sorry to be pedantic, but I want to nail this down.
> It's still broken with HZ=1000, but without Ingo's patch, right?

I have to try that combination... Please, allow for a few hours and I'll
post the results.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
