Subject: Re: -mm merge plans for 2.6.23
From: Eric St-Laurent <ericstl34@sympatico.ca>
In-Reply-To: <46A6E1A1.4010508@yahoo.com.au>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <200707102015.44004.kernel@kolivas.org>
	 <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	 <46A57068.3070701@yahoo.com.au>
	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	 <46A58B49.3050508@yahoo.com.au>
	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	 <46A6CC56.6040307@yahoo.com.au>  <46A6D7D2.4050708@gmail.com>
	 <1185341449.7105.53.camel@perkele>  <46A6E1A1.4010508@yahoo.com.au>
Content-Type: text/plain
Date: Wed, 25 Jul 2007 02:44:32 -0400
Message-Id: <1185345872.7105.110.camel@perkele>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Rene Herman <rene.herman@gmail.com>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-25-07 at 15:37 +1000, Nick Piggin wrote:

> OK, this is where I start to worry. Swap prefetch AFAIKS doesn't fix
> the updatedb problem very well, because if updatedb has caused swapout
> then it has filled memory, and swap prefetch doesn't run unless there
> is free memory (not to mention that updatedb would have paged out other
> files as well).
> 
> And drop behind doesn't fix your usual problem where you are downloading
> from a server, because that is use-once write(2) data which is the
> problem. And this readahead-based drop behind also doesn't help if data
> you were reading happened to be a sequence of small files, or otherwise
> not in good readahead order.
> 
> Not to say that neither fix some problems, but for such conceptually
> big changes, it should take a little more effort than a constructed test
> case and no consideration of the alternatives to get it merged.


Sorry for the confusion.

For swap prefetch I should have said "some people claim that it fix
their problem". I didn't want to hurt anybody feelings, some people are
tired to hear others speak hypothetically about this patch, as it
work-for-them (TM).

I don't experience the problem. Can't help.

For drop behind it fix half the problem. The read case is handled
perfectly by Peter's patch. And the copy (read+write) is unchanged. My
test case demonstrate it very easily, just look at the numbers.

So, I agree with you that drop behind doesn't fix the write() case.
Peter has said so himself when I offered to test his patch.

As I do experience this problem, I have written a small test program and
batch file to help push the patch for acceptance.  I'm very willing to
help improve the test cases, test patches and write code, time
permitting.

About this very subject, earlier this year this Andrew suggested me to
came up with a test case to demonstrate my problem, well finally I've
done so.

http://lkml.org/lkml/2007/3/3/164
http://lkml.org/lkml/2007/3/3/166

Lastly, I would go as far to say that the use-once read then copy fix
must also work with copies over NFS. I don't know if NFS change the
workload on the client station versus the local case, and I don't know
if it's still possible to consider data copied this way as use-once.


- Eric


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
