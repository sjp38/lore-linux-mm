From: "Frank A. Kingswood" <frank@kingswood-consulting.co.uk>
Subject: Re: -mm merge plans for 2.6.23
Date: Wed, 25 Jul 2007 18:55:43 +0100
Message-ID: <f882qv$grl$1@sea.gmane.org>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>		<200707102015.44004.kernel@kolivas.org>		<9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>		<46A57068.3070701@yahoo.com.au>		<2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>		<46A58B49.3050508@yahoo.com.au>		<2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>		<46A6CC56.6040307@yahoo.com.au>
	<46A6D7D2.4050708@gmail.com>	<1185341449.7105.53.camel@perkele>
	<46A6E1A1.4010508@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <ck-bounces@vds.kolivas.org>
In-Reply-To: <46A6E1A1.4010508@yahoo.com.au>
List-Unsubscribe: <http://bhhdoa.org.au/mailman/listinfo/ck>,
	<mailto:ck-request@vds.kolivas.org?subject=unsubscribe>
List-Archive: <http://bhhdoa.org.au/pipermail/ck>
List-Post: <mailto:ck@vds.kolivas.org>
List-Help: <mailto:ck-request@vds.kolivas.org?subject=help>
List-Subscribe: <http://bhhdoa.org.au/mailman/listinfo/ck>,
	<mailto:ck-request@vds.kolivas.org?subject=subscribe>
Sender: ck-bounces@vds.kolivas.org
Errors-To: ck-bounces@vds.kolivas.org
To: ck@vds.kolivas.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

Nick Piggin wrote:
> OK, this is where I start to worry. Swap prefetch AFAIKS doesn't fix
> the updatedb problem very well, because if updatedb has caused swapout
> then it has filled memory, and swap prefetch doesn't run unless there
> is free memory (not to mention that updatedb would have paged out other
> files as well).

It is *not* about updatedb. That is just a trivial case which people 
notice. Therefore fixing updatedb to be nicer, as was discussed at 
various points in this thread, is *not* the solution.
Most users are also *not*at*all* interested in kernel builds as a metric 
of system performance.

When I'm at work, I run a large, commercial, engineering application. 
While running, it takes most of the system memory (4GB and up), and it 
reads and writes very large files. Swap prefetch noticeably helps my 
desktop too. Can I measure it? Not sure. Can people on lkml fix the 
application? Certainly not.

Frank
