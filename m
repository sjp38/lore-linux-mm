Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 0F8596B009F
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 06:05:00 -0400 (EDT)
Message-ID: <1346839487.2600.24.camel@twins>
Subject: Re: [RFC 0/5] forced comounts for cgroups.
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 05 Sep 2012 12:04:47 +0200
In-Reply-To: <20120905093204.GL3195@dhcp-172-17-108-109.mtv.corp.google.com>
References: <1346768300-10282-1-git-send-email-glommer@parallels.com>
	 <20120904214602.GA9092@dhcp-172-17-108-109.mtv.corp.google.com>
	 <5047074D.1030104@parallels.com>
	 <20120905081439.GC3195@dhcp-172-17-108-109.mtv.corp.google.com>
	 <50470A87.1040701@parallels.com>
	 <20120905082947.GD3195@dhcp-172-17-108-109.mtv.corp.google.com>
	 <50470EBF.9070109@parallels.com>
	 <20120905084740.GE3195@dhcp-172-17-108-109.mtv.corp.google.com>
	 <1346835993.2600.9.camel@twins>
	 <20120905093204.GL3195@dhcp-172-17-108-109.mtv.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org

On Wed, 2012-09-05 at 02:32 -0700, Tejun Heo wrote:
> Hey, again.
>=20
> On Wed, Sep 05, 2012 at 11:06:33AM +0200, Peter Zijlstra wrote:
> > Doing all this runtime is just going to make the mess even bigger,
> > because now we have to deal with even more stupid cases.
> >=20
> > So either we go and try to contain this mess as proposed by Glauber or
> > we go delete controllers.. I've had it with this crap.
>=20
> cpuacct is rather unique tho.  I think it's gonna be silly whether the
> hierarchy is unified or not.
>=20
> 1. If they always can live on the exact same hierarchy, there's no
>    point in having the two separate.  Just merge them.
>=20
> 2. If they need differing levels of granularity, they either need to
>    do it completely separately as they do now or have some form of
>    dynamic optimization if absolutely necesary.
>=20
> So, I think that choice is rather separate from other issues.  If
> cpuacct is gonna be kept, I'd just keep it separate and warn that it
> incurs extra overhead for the current users if for nothing else.
> Otherwise, kill it or merge it into cpu.

Quite, hence my 'proposal' to remove cpuacct.

There was some whining last time Glauber proposed this, but the one
whining never convinced and has gone away from Linux, so lets just do
this.

Lets make cpuacct print a deprecated msg to dmesg for a few releases and
make cpu do all this.

The co-mounting stuff would have been nice for cpusets as well, knowing
all your tasks are affine to a subset of cpus allows for a few
optimizations (smaller cpumask iterations), but I guess we'll have to do
that dynamically, we'll just have to see how ugly that is.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
