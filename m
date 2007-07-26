Message-ID: <46A85463.80405@yahoo.com.au>
Date: Thu, 26 Jul 2007 17:59:31 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: -mm merge plans for 2.6.23
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>	 <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com>	 <1185341449.7105.53.camel@perkele> <46A6E1A1.4010508@yahoo.com.au>	 <2c0942db0707250909r435fef75sa5cbf8b1c766000b@mail.gmail.com>	 <20070725215717.df1d2eea.akpm@linux-foundation.org>	 <2c0942db0707252333uc7631fduadb080193f6ad323@mail.gmail.com>	 <20070725235037.e59f30fc.akpm@linux-foundation.org> <2c0942db0707260043h18d878baq9b3be72c01e2680a@mail.gmail.com>
In-Reply-To: <2c0942db0707260043h18d878baq9b3be72c01e2680a@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Lee <ray-lk@madrabbit.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Eric St-Laurent <ericstl34@sympatico.ca>, Rene Herman <rene.herman@gmail.com>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ray Lee wrote:

> Another is a more philosophical hangup -- running a process that polls
> periodically to improve system performance seems backward.

You mean like the kprefetchd of swap prefetch? ;)


> Okay, so
> that's my problem to get over, not yours.

If it was a problem you could add some event trigger to wake it up.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
