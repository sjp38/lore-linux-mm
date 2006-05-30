Message-ID: <447C055A.9070906@sgi.com>
Date: Tue, 30 May 2006 10:42:02 +0200
From: Jes Sorensen <jes@sgi.com>
MIME-Version: 1.0
Subject: Re: [Patch 0/17] PTI: Explation of Clean Page Table Interface
References: <Pine.LNX.4.61.0605301334520.10816@weill.orchestra.cse.unsw.EDU.AU> <yq0irnot028.fsf@jaguar.mkp.net> <Pine.LNX.4.61.0605301830300.22882@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <Pine.LNX.4.61.0605301830300.22882@weill.orchestra.cse.unsw.EDU.AU>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Paul Cameron Davies wrote:
> Hi Jes
> 
> It is currently causing a degradation, but we are in the process
> of performance tuning.
> 
> There is a small cost associated with the PTI at the moment.

Hi Paul,

Bugger! I was hoping it was the other way round :( 3.5% falls into the
bucket of pretty expensive in my book, so I'll cross my fingers that
you nail the source of it.

Cheers,
Jes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
