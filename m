Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 78DEB6B0095
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 10:19:38 -0400 (EDT)
Message-ID: <1340720366.21991.84.camel@twins>
Subject: Re: [PATCH] memcg: first step towards hierarchical controller
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 26 Jun 2012 16:19:26 +0200
In-Reply-To: <20120626141127.GA27816@cmpxchg.org>
References: <1340717428-9009-1-git-send-email-glommer@parallels.com>
	 <20120626141127.GA27816@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>

On Tue, 2012-06-26 at 16:11 +0200, Johannes Weiner wrote:
>=20
> Should the warning be emitted for any memcg, not just the parent?  If
> somebody takes notice of the changed semantics, it's better to print
> the warning on the first try to disable hierarchies instead of holding
> back until they walk up the tree and try to change it in the root.
> Still forbid disabling at lower levels, just be more eager to inform
> the people trying it.=20

*blink* You mean you can mix-and-match use_hierarchy over the hierarchy?
Can I have some of those drugs? It must be strong and powerful stuff
that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
