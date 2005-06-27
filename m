Date: Mon, 27 Jun 2005 09:08:14 -0400 (EDT)
From: Rik Van Riel <riel@redhat.com>
Subject: Re: [PATCH] 2/2 swap token tuning
In-Reply-To: <1119877465.25717.4.camel@lycan.lan>
Message-ID: <Pine.LNX.4.61.0506270907110.18834@chimarrao.boston.redhat.com>
References: <Pine.LNX.4.61.0506261827500.18834@chimarrao.boston.redhat.com>
  <Pine.LNX.4.61.0506261835000.18834@chimarrao.boston.redhat.com>
 <1119877465.25717.4.camel@lycan.lan>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schlemmer <azarah@nosferatu.za.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Song Jiang <sjiang@lanl.gov>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Jun 2005, Martin Schlemmer wrote:

> -+				sem_is_read_locked(mm->mmap_sem))
> +                               sem_is_read_locked(&mm->mmap_sem))

Yes, you are right.  I sent out the patch before the weekend
was over, before having tested it locally ;)

My compile hit the error a few minutes after I sent out the
mail, doh ;)

Andrew has a fixed version of the patch already.

-- 
The Theory of Escalating Commitment: "The cost of continuing mistakes is
borne by others, while the cost of admitting mistakes is borne by yourself."
  -- Joseph Stiglitz, Nobel Laureate in Economics
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
