Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id B1DE66B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 06:46:14 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so9536486lbj.14
        for <linux-mm@kvack.org>; Mon, 02 Jul 2012 03:46:12 -0700 (PDT)
Date: Mon, 2 Jul 2012 13:46:09 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH] slab: Fix a tpyo in commit 8c138b "slab: Get rid of
 obj_size macro"
In-Reply-To: <4FF17733.6020703@parallels.com>
Message-ID: <alpine.LFD.2.02.1207021346030.1916@tux.localdomain>
References: <1341210550-11038-1-git-send-email-feng.tang@intel.com> <4FF1714A.7050400@parallels.com> <4FF17733.6020703@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Feng Tang <feng.tang@intel.com>, linux-kernel@vger.kernel.org, fengguang.wu@intel.com, sfr@canb.auug.org.au, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Mon, 2 Jul 2012, Glauber Costa wrote:
> > I saw another bug in a patch that ended up not getting in, and was
> > reported to Christoph, that was exactly due to a typo between size and
> > object-size.
> > 
> > So first:
> > 
> > Acked-by: Glauber Costa <glommer@parallels.com>
> > 
> > But this also means that that confusion can have been made in other
> > points. I suggest we take an extensive look into that to make sure there
> > aren't more.
> > 
> 
> Which I just did. I also tried to pay attention to another simple
> conversion spots like that. We seem to be fine.

Applied, thanks guys!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
