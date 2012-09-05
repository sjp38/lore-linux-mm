Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 8DC616B005D
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 05:07:27 -0400 (EDT)
Message-ID: <1346836041.2600.10.camel@twins>
Subject: Re: [RFC 0/5] forced comounts for cgroups.
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 05 Sep 2012 11:07:21 +0200
In-Reply-To: <1346835993.2600.9.camel@twins>
References: <1346768300-10282-1-git-send-email-glommer@parallels.com>
	 <20120904214602.GA9092@dhcp-172-17-108-109.mtv.corp.google.com>
	 <5047074D.1030104@parallels.com>
	 <20120905081439.GC3195@dhcp-172-17-108-109.mtv.corp.google.com>
	 <50470A87.1040701@parallels.com>
	 <20120905082947.GD3195@dhcp-172-17-108-109.mtv.corp.google.com>
	 <50470EBF.9070109@parallels.com>
	 <20120905084740.GE3195@dhcp-172-17-108-109.mtv.corp.google.com>
	 <1346835993.2600.9.camel@twins>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org

On Wed, 2012-09-05 at 11:06 +0200, Peter Zijlstra wrote:
>=20
> So either we go and try to contain this mess as proposed by Glauber or
> we go delete controllers.. I've had it with this crap.
>=20
>=20

Glauber, the other approach is sending a patch that doesn't touch
cgroup.c but only the controllers and I'll merge it regardless of what
tj thinks.

We need some movement here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
