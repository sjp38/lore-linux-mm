Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id AD5456B0062
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 18:21:48 -0400 (EDT)
Date: Tue, 19 Jun 2012 15:21:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] mm/memblock: fix overlapping allocation when
 doubling reserved array
Message-Id: <20120619152147.9f377a64.akpm@linux-foundation.org>
In-Reply-To: <4FE0F675.3050201@hp.com>
References: <1340063278-31601-1-git-send-email-greg.pearson@hp.com>
	<20120619213315.GL32733@google.com>
	<4FE0F675.3050201@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Pearson, Greg" <greg.pearson@hp.com>
Cc: Tejun Heo <tj@kernel.org>, "hpa@linux.intel.com" <hpa@linux.intel.com>, "shangw@linux.vnet.ibm.com" <shangw@linux.vnet.ibm.com>, "mingo@elte.hu" <mingo@elte.hu>, "yinghai@kernel.org" <yinghai@kernel.org>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, 19 Jun 2012 22:00:22 +0000
"Pearson, Greg" <greg.pearson@hp.com> wrote:

> I wasn't quite sure what to do about that at first either, I read 
> "Documentation/SubmittingPatches" and it says:
> 
> "The Signed-off-by: tag indicates that the signer was involved in the
> development of the patch, or that he/she was in the patch's delivery path."
> 
> Since Yinghai contributed some code that is in the current version of 
> the patch I thought the "Signed-off-by" tag would be ok, but if 
> something else is more appropriate I have no problem re-cutting the 
> patch to make the chain of custody more clear.

Yup, we shouldn't expect people to be able to magically infer
fine-grained details such as this from hints embedded in the signoff
trail.  Fortunately we can write stuff in English ;)

I added

: This patch contains contributions from Yinghai Lu.

to the changelog.  Simple, huh? :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
