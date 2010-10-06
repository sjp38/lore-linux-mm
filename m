Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5F13E6B0071
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 16:56:18 -0400 (EDT)
Date: Wed, 6 Oct 2010 15:56:13 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [UnifiedV4 00/16] The Unified slab allocator (V4)
In-Reply-To: <1286379979.1897.0.camel@castor.rsk>
Message-ID: <alpine.DEB.2.00.1010061554040.8083@router.home>
References: <20101005185725.088808842@linux.com>  <AANLkTinPU4T59PvDH1wX2Rcy7beL=TvmHOZh_wWuBU-T@mail.gmail.com>  <4CAC577F.9040401@rsk.demon.co.uk>  <AANLkTikr9B5Yb+Owe3t+Rb8KBO33DE=9YBQZ_1+Gwcu8@mail.gmail.com> <1286379979.1897.0.camel@castor.rsk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, npiggin@kernel.dk, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

Created a unified branch in my slab.git on kernel.org as well. Based on
Pekka's for-next branch. There was an additional conflict caused by
another merge to for-next that was fixed.

git pull git://git.kernel.org/pub/scm/linux/kernel/git/christoph/slab.git unified


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
