Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2FF0A6B6A62
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 12:16:14 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id e185so8478750oih.18
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 09:16:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i13sor7535566otk.105.2018.12.03.09.16.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 09:16:13 -0800 (PST)
MIME-Version: 1.0
References: <20181022201317.8558C1D8@viggo.jf.intel.com> <ffeb6225-6d5c-099e-3158-4711c879ec23@gmail.com>
 <48d78370-438d-65fa-370c-4cf61a27ed3d@intel.com>
In-Reply-To: <48d78370-438d-65fa-370c-4cf61a27ed3d@intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 3 Dec 2018 09:16:01 -0800
Message-ID: <CAPcyv4jU1A93J4pqme3bGHE_KJE2TZ_F9pncgesuksT8YaR-FQ@mail.gmail.com>
Subject: Re: [PATCH 0/9] Allow persistent memory to be used like normal RAM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Brice Goglin <brice.goglin@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dave Jiang <dave.jiang@intel.com>, zwisler@kernel.org, Vishal L Verma <vishal.l.verma@intel.com>, Tom Lendacky <thomas.lendacky@amd.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, "Huang, Ying" <ying.huang@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Keith Busch <keith.busch@intel.com>

On Mon, Dec 3, 2018 at 8:56 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 12/3/18 1:22 AM, Brice Goglin wrote:
> > Le 22/10/2018 =C3=A0 22:13, Dave Hansen a =C3=A9crit :
> > What happens on systems without an HMAT? Does this new memory get merge=
d
> > into existing NUMA nodes?
>
> It gets merged into the persistent memory device's node, as told by the
> firmware.  Intel's persistent memory should always be in its own node,
> separate from DRAM.
>
> > Also, do you plan to have a way for applications to find out which NUMA
> > nodes are "real DRAM" while others are "pmem-backed"? (something like a
> > new attribute in /sys/devices/system/node/nodeX/) Or should we use HMAT
> > performance attributes for this?
>
> The best way is to use the sysfs-generic interfaces to the HMAT that
> Keith Busch is pushing.  In the end, we really think folks will only
> care about the memory's performance properties rather than whether it's
> *actually* persistent memory or not.

It's also important to point out that "persistent memory" by itself is
an ambiguous memory type. It's anything from new media with distinct
performance characteristics to battery backed DRAM. I.e. the
performance of "persistent memory" may be indistinguishable from "real
DRAM".
