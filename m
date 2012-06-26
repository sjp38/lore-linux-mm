Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 32F516B00A0
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 10:41:31 -0400 (EDT)
Message-ID: <1340721669.21991.85.camel@twins>
Subject: Re: [PATCH] memcg: first step towards hierarchical controller
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 26 Jun 2012 16:41:09 +0200
In-Reply-To: <20120626143818.GB27816@cmpxchg.org>
References: <1340717428-9009-1-git-send-email-glommer@parallels.com>
	 <20120626141127.GA27816@cmpxchg.org> <1340720366.21991.84.camel@twins>
	 <20120626143818.GB27816@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>

On Tue, 2012-06-26 at 16:38 +0200, Johannes Weiner wrote:
> But you can't disable the hierarchy if you have a hierarchy-enabled
> parent, which we try to make the new default.=20

Ah ok.. so still crazy, but slightly less insane ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
