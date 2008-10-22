Received: by wf-out-1314.google.com with SMTP id 28so3272852wfc.11
        for <linux-mm@kvack.org>; Wed, 22 Oct 2008 13:48:56 -0700 (PDT)
Message-ID: <84144f020810221348j536f0d84vca039ff32676e2cc@mail.gmail.com>
Date: Wed, 22 Oct 2008 23:48:56 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: SLUB defrag pull request?
In-Reply-To: <E1KskHI-0002AF-Hz@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1223883004.31587.15.camel@penberg-laptop>
	 <E1Ks1hu-0002nN-9f@pomaz-ex.szeredi.hu>
	 <48FE6306.6020806@linux-foundation.org>
	 <E1KsXrY-0000AU-C4@pomaz-ex.szeredi.hu>
	 <Pine.LNX.4.64.0810220822500.30851@quilx.com>
	 <E1Ksjed-00023D-UB@pomaz-ex.szeredi.hu>
	 <Pine.LNX.4.64.0810221252570.3562@quilx.com>
	 <E1Ksk3g-00027r-Lp@pomaz-ex.szeredi.hu>
	 <Pine.LNX.4.64.0810221315080.26671@quilx.com>
	 <E1KskHI-0002AF-Hz@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: cl@linux-foundation.org, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 22, 2008 at 11:26 PM, Miklos Szeredi <miklos@szeredi.hu> wrote:
> Because you don't _need_ a reliable reference to access the contents
> of the dentry.  The dentry is still there after being freed, as long
> as the underlying slab is there and isn't being reused for some other
> purpose.  But you can easily ensure that from the slab code.
>
> Hmm?

Actually, when debugging is enabled, it's customary to poison the
object, for example (see free_debug_processing() in mm/slub.c). So we
really can't "easily ensure" that in the allocator unless we by-pass
all the current debugging code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
