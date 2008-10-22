Received: by wa-out-1112.google.com with SMTP id j37so1746833waf.22
        for <linux-mm@kvack.org>; Wed, 22 Oct 2008 14:12:02 -0700 (PDT)
Message-ID: <84144f020810221412uae54f1eudafa4c8fefea9753@mail.gmail.com>
Date: Thu, 23 Oct 2008 00:12:02 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: SLUB defrag pull request?
In-Reply-To: <E1Ksksa-0002Iq-EV@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1223883004.31587.15.camel@penberg-laptop>
	 <E1KsXrY-0000AU-C4@pomaz-ex.szeredi.hu>
	 <Pine.LNX.4.64.0810220822500.30851@quilx.com>
	 <E1Ksjed-00023D-UB@pomaz-ex.szeredi.hu>
	 <Pine.LNX.4.64.0810221252570.3562@quilx.com>
	 <E1Ksk3g-00027r-Lp@pomaz-ex.szeredi.hu>
	 <Pine.LNX.4.64.0810221315080.26671@quilx.com>
	 <E1KskHI-0002AF-Hz@pomaz-ex.szeredi.hu>
	 <84144f020810221348j536f0d84vca039ff32676e2cc@mail.gmail.com>
	 <E1Ksksa-0002Iq-EV@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: cl@linux-foundation.org, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi Miklos,

On Thu, Oct 23, 2008 at 12:04 AM, Miklos Szeredi <miklos@szeredi.hu> wrote:
>> Actually, when debugging is enabled, it's customary to poison the
>> object, for example (see free_debug_processing() in mm/slub.c). So we
>> really can't "easily ensure" that in the allocator unless we by-pass
>> all the current debugging code.
>
> Thank you, that does actually answer my question.  I would still think
> it's a good sacrifice to no let the dentries be poisoned for the sake
> of a simpler dentry defragmenter.

To be honest, I haven't paid enough attention to the discussion to see
how much simpler it would be. But I don't like the idea of forcibly
disabling debugging for slab caches because of a new core feature in
the allocator. Keep in mind that it's not just dentries we're talking
about here, we're defragmenting inodes as well.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
