Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0E1146B0069
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 13:52:20 -0500 (EST)
Date: Mon, 21 Nov 2011 19:52:15 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Message-ID: <20111121185215.GA1673@x4.trippels.de>
References: <1321866988.2552.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121131531.GA1679@x4.trippels.de>
 <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121153621.GA1678@x4.trippels.de>
 <1321890510.10470.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121161036.GA1679@x4.trippels.de>
 <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121173556.GA1673@x4.trippels.de>
 <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrew Bresticker <abrestic@google.com>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>

On 2011.11.21 at 19:39 +0100, Eric Dumazet wrote:
> Le lundi 21 novembre 2011 a 18:35 +0100, Markus Trippelsdorf a ecrit :
> 
> > New one:
> 
> ...
> 
> I was just wondering if you were using CONFIG_CGROUPS=y, and if yes, if
> you could try to disable it.

# CONFIG_CGROUPS is not set

(I never enable CGROUPS on my machines)

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
