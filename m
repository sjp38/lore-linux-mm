Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id C46DC6B0069
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 06:28:35 -0400 (EDT)
Message-ID: <4FF17733.6020703@parallels.com>
Date: Mon, 2 Jul 2012 14:25:55 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slab: Fix a tpyo in commit 8c138b "slab: Get rid of obj_size
 macro"
References: <1341210550-11038-1-git-send-email-feng.tang@intel.com> <4FF1714A.7050400@parallels.com>
In-Reply-To: <4FF1714A.7050400@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Feng Tang <feng.tang@intel.com>
Cc: penberg@kernel.org, linux-kernel@vger.kernel.org, fengguang.wu@intel.com, sfr@canb.auug.org.au, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>


> I saw another bug in a patch that ended up not getting in, and was
> reported to Christoph, that was exactly due to a typo between size and
> object-size.
> 
> So first:
> 
> Acked-by: Glauber Costa <glommer@parallels.com>
> 
> But this also means that that confusion can have been made in other
> points. I suggest we take an extensive look into that to make sure there
> aren't more.
> 

Which I just did. I also tried to pay attention to another simple
conversion spots like that. We seem to be fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
