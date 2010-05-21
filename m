Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 827D16B01B8
	for <linux-mm@kvack.org>; Fri, 21 May 2010 03:29:38 -0400 (EDT)
From: "Kleen, Andi" <andi.kleen@intel.com>
Date: Fri, 21 May 2010 08:29:09 +0100
Subject: RE: [PATCH] online CPU before memory failed in pcpu_alloc_pages()
Message-ID: <F4DF93C7785E2549970341072BC32CD722717DBB@irsmsx503.ger.corp.intel.com>
References: <1274163442-7081-1-git-send-email-chaohong_guo@linux.intel.com>
 <20100520134359.fdfb397e.akpm@linux-foundation.org>
In-Reply-To: <20100520134359.fdfb397e.akpm@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, minskey guo <chaohong_guo@linux.intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "prarit@redhat.com" <prarit@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Guo, Chaohong" <chaohong.guo@intel.com>, Tejun Heo <tj@kernel.org>, "stable@kernel.org" <stable@kernel.org>
List-ID: <linux-mm.kvack.org>

>
>How serious is this issue?  Just a warning?  Dead box?

It's pretty much a showstopper for memory hotadd with a new node.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
