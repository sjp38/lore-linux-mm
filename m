Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 17C136B0085
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 07:19:15 -0400 (EDT)
Received: by iwn41 with SMTP id 41so2431887iwn.14
        for <linux-mm@kvack.org>; Wed, 06 Oct 2010 04:19:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4CAC577F.9040401@rsk.demon.co.uk>
References: <20101005185725.088808842@linux.com>
	<AANLkTinPU4T59PvDH1wX2Rcy7beL=TvmHOZh_wWuBU-T@mail.gmail.com>
	<4CAC577F.9040401@rsk.demon.co.uk>
Date: Wed, 6 Oct 2010 14:19:13 +0300
Message-ID: <AANLkTikr9B5Yb+Owe3t+Rb8KBO33DE=9YBQZ_1+Gwcu8@mail.gmail.com>
Subject: Re: [UnifiedV4 00/16] The Unified slab allocator (V4)
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, npiggin@kernel.dk, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Wed, Oct 6, 2010 at 2:03 PM, Richard Kennedy <richard@rsk.demon.co.uk> wrote:
> What tree are these patches against ? I'm getting patch failures on the
> main tree.

The 'slab/next' branch of slab.git:

http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=summary

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
