From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: NUMA BOF @OLS
Date: Fri, 22 Jun 2007 12:14:58 +0200
Message-ID: <200706221214.58823.arnd@arndb.de>
References: <Pine.LNX.4.64.0706211316150.9220@schroedinger.engr.sgi.com> <200706220112.51813.arnd@arndb.de> <Pine.LNX.4.64.0706211844420.11754@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754345AbXFVKQh@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0706211844420.11754@schroedinger.engr.sgi.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On Friday 22 June 2007, Christoph Lameter wrote:
>=20
> On Fri, 22 Jun 2007, Arnd Bergmann wrote:
>=20
> > - Interface for preallocating hugetlbfs pages per node instead of s=
ystem wide
>=20
> We may want to get a bit higher level than that. General way of=20
> controlling subsystem use on nodes. One wants to restrict the slab=20
> allocator and the kernel etc on nodes too.
>=20
> How will this interact with the other NUMA policy specifications?

I guess that's what I'd like to discuss at the BOF. I frequently
get requests from users that need to have some interface for it:
Application currently break if they try to use /proc/sys/vm/nr_hugepage=
s
in combination with numactl --membind.

> > - architecture independent in-kernel API for enumerating CPU socket=
s with
> > =A0 multicore processors (not sure if that's the same as your exist=
ing subject).
>=20
> Not sure what you mean by this. We already have a topology interface =
and=20
> the scheduler knows about these things.

I'm not referring to user interfaces or scheduling. It's probably not r=
eally
a NUMA topic, but we currently use the topology interfaces for enumerat=
ing
sockets on systems that are not really NUMA. This includes stuff like
per-socket=20
 * cpufreq settings (these have their own logic currently)
 * IOMMU
 * performance counters
 * thermal management
 * local interrupt controller
 * PCI/HT host bridge

If you have a system with multiple CPUs in one socket and either multip=
le
sockets in one NUMA node or no NUMA at all,  you have no way of properl=
y
enumerating the sockets.  I'd like to discuss what such an interface
would need to look like to be useful for all architectures.

	Arnd <><
