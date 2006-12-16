Date: Sat, 16 Dec 2006 19:44:50 +0100
From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: Recent mm changes leading to filesystem corruption?
Message-ID: <20061216184450.GA21129@deprecation.cyrius.com>
References: <20061216155044.GA14681@deprecation.cyrius.com> <Pine.LNX.4.64.0612161812090.21270@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0612161812090.21270@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, debian-kernel@lists.debian.org
List-ID: <linux-mm.kvack.org>

* Hugh Dickins <hugh@veritas.com> [2006-12-16 18:20]:
> Very disturbing.  I'm not aware of any problem with them, and we
> surely wouldn't have released 2.6.19 with any known-corrupting patches
> in.  There's some doubts about 2.6.19 itself in the links below: were
> it not for those, I'd suspect a mismerge of the pieces into 2.6.18,
> perhaps a hidden dependency on something else.  I'll ponder a little,
> but let's CC linux-mm in case someone there has an idea.

Do you think http://article.gmane.org/gmane.linux.kernel/473710 might
be related?
-- 
Martin Michlmayr
http://www.cyrius.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
