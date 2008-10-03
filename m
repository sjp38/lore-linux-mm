Date: Fri, 3 Oct 2008 14:17:31 -0300
From: "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
Subject: Re: [PATCH 00/32] Swap over NFS - v19
Message-ID: <20081003141731.37bda8f3@doriath.conectiva>
In-Reply-To: <20081002130504.927878499@chello.nl>
References: <20081002130504.927878499@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Em Thu, 02 Oct 2008 15:05:04 +0200
Peter Zijlstra <a.p.zijlstra@chello.nl> escreveu:

| Patches are against: v2.6.27-rc5-mm1
| 
| This release features more comments and (hopefully) better Changelogs.
| Also the netns stuff got sorted and ipv6 will now build and not oops
| on boot ;-)
| 
| The first 4 patches are cleanups and can go in if the respective maintainers
| agree.
| 
| The code is lightly tested but seems to work on my default config.
| 
| Let's get this ball rolling...

 What's the best way to test this? Create a swap in a NFS mount
point and stress it?

-- 
Luiz Fernando N. Capitulino

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
